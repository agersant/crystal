require( "src/utils/OOP" );
local Teams = require( "src/combat/Teams" );

local TargetSelector = Class( "TargetSelector" );



-- IMPLEMENTATION

TargetSelector.init = function( self, targets )
	self._targets = targets;
end

local passesFilters = function( self, filters, target )
	for _, filter in ipairs( filters ) do
		if not filter( target ) then
			return false;
		end
	end
	return true;
end

local getAll = function( self, filters )
	local out = {};
	for i, target in ipairs( self._targets ) do
		if passesFilters( self, filters, target ) then
			table.insert( out, target );
		end
	end
	return out;
end

local getFittest = function( self, filters, rank )
	local bestScore = nil;
	local bestTarget = nil;
	for i, target in ipairs( self._targets ) do
		if passesFilters( self, filters, target ) then
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

local isNot = function( entity )
	return function( target )
		return target ~= entity;
	end
end

local rankByDistanceTo = function( entity )
	return function( target )
		return -entity:distance2ToEntity( target );
	end
end

local isAlive = function( entity )
	return not entity:isDead();
end



-- PUBLIC API

TargetSelector.getAllies = function( self, entity )
	return getAll( self, { isAlive, isAllyOf( entity ), isNot( entity ) } );
end

TargetSelector.getEnemies = function( self, entity )
	return getAll( self, { isAlive, isEnemyOf( entity ), isNot( entity ) } );
end

TargetSelector.getNearestEnemy = function( self, entity )
	return getFittest( self, { isAlive, isEnemyOf( entity ), isNot( entity ) }, rankByDistanceTo( entity ) );
end

TargetSelector.getNearestAlly = function( self, entity )
	return getFittest( self, { isAlive, isAllyOf( entity ), isNot( entity ) }, rankByDistanceTo( entity ) );
end



return TargetSelector;
