require( "src/utils/OOP" );
local Teams = require( "src/scene/combat/Teams" );

local TargetSelector = Class( "TargetSelector" );



-- IMPLEMENTATION

TargetSelector.init = function( self, targets )
	self._targets = targets;
end

local getAll = function( self, filter )
	local out = {};
	for i, target in ipairs( self._targets ) do
		if filter( target ) then
			table.insert( out, target );
		end
	end
	return out;
end

local getFittest = function( self, filter, rank )
	local bestScore = nil;
	local bestTarget = nil;
	for i, target in ipairs( self._targets ) do
		if filter( target ) then
			local score = rank( target );
			if not bestScore or score > bestScore then
				bestScore = score;
				bestTarget = target;
			end
		end
	end
	return bestTarget;
end

local isAllyOf = function( entity )
	return function( target )
		return Teams:areAllies( entity:getTeam(), target:getTeam() );
	end
end

local isEnemyOf = function( entity )
	return function( target )
		return Teams:areEnemies( entity:getTeam(), target:getTeam() );
	end
end

local rankByDistanceTo = function( entity )
	return function( target )
		return -entity:distance2ToEntity( target );
	end
end



-- PUBLIC API

TargetSelector.getAllies = function( self, entity )
	return getAll( self, isAllyOf( entity ) );
end

TargetSelector.getEnemies = function( self, entity )
	return getAll( self, isEnemyOf( entity ) );
end

TargetSelector.getNearestEnemy = function( self, entity )
	return getFittest( self, isEnemyOf( entity ), rankByDistanceTo( entity ) );
end

TargetSelector.getNearestAlly = function( self, entity )
	return getFittest( self, isAllyOf( entity ), rankByDistanceTo( entity ) );
end



return TargetSelector;
