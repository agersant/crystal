require( "src/utils/OOP" );
local Stat = require( "src/scene/entity/Stat" );
local Damage = require( "src/scene/combat/Damage" );
local Teams = require( "src/scene/combat/Teams" );

local CombatComponent = Class( "CombatComponent" );



-- IMPLEMENTATION

local mitigateDamage = function( self, damage )
	local rawAmount = damage:getAmount();
	local defense = self._defense:getValue();
	local mitigationFactor = defense / ( defense + 100 );
	local mitigatedAmount = rawAmount * ( 1 - mitigationFactor );
	return mitigatedAmount;
end

local combatableIter = function( filter )
	return function( self, i )
		i = i + 1;
		local numEntities = #self._peers;
		while i <= numEntities and not filter( self, self._peers[i] ) do
			i = i + 1;
		end
		if i <= numEntities then
			return i, self._peers[i];
		end
	end
end

local enemyIter = combatableIter( function( self, other ) return self._entity:isEnemy( other ) end );
local allyIter = combatableIter( function( self, other ) return self._entity:isAlly( other ) end );




-- PUBLIC API

CombatComponent.init = function( self, entity, peers )
	assert( entity );
	self._peers = peers;
	self:setTeam( Teams.wild );
	self._entity = entity;
	self._health = Stat:new( 500, 0, nil );
	self._defense = Stat:new( 10, 1, nil );
	self._strength = Stat:new( 10, 1, nil );
	self._attackRating = Stat:new( 1.5, 0, nil );
	self._critRate = Stat:new( .02, 0, 1 );
	self._critRating = Stat:new( 2, 1, nil );
end

CombatComponent.setTeam = function( self, team )
	assert( Teams:isValid( team ) );
	self._team = team;
end

CombatComponent.isAlly = function( self, otherCombatComponent )
	return Teams:areAllies( self._team, otherCombatComponent._team );
end

CombatComponent.isEnemy = function( self, otherCombatComponent )
	return Teams:areEnemies( self._team, otherCombatComponent._team );
end

CombatComponent.allies = function( self )
	return allyIter, self, 0;
end

CombatComponent.enemies = function( self )
	return enemyIter, self, 0;
end

CombatComponent.inflictDamageTo = function( self, target )
	local effectiveStrength = self._strength:getValue() * self._attackRating:getValue();
	local isCrit = math.random() < self._critRate:getValue();
	if isCrit then
		effectiveStrength = effectiveStrength * self._critRating:getValue();
	end
	local damage = Damage:new( effectiveStrength, self._entity );
	target:receiveDamage( damage );
end

CombatComponent.receiveDamage = function( self, damage )
	if self:isDead() then
		return;
	end
	self._entity:signal( "takeHit", damage );
	local effectiveDamage = mitigateDamage( self, damage );
	self._health:substract( effectiveDamage );
	if self:isDead() then
		self._entity:signal( "death" );
	end
end

CombatComponent.isDead = function( self )
	return self._health:getValue() == 0;
end



return CombatComponent;
