require( "src/utils/OOP" );
local Stat = require( "src/scene/entity/Stat" );
local Damage = require( "src/scene/combat/Damage" );

local CombatComponent = Class( "CombatComponent" );



-- IMPLEMENTATION

local mitigateDamage = function( self, damage )
	local rawAmount = damage:getAmount();
	local defense = self._defense:getValue();
	local mitigationFactor = defense / ( defense + 100 );
	local mitigatedAmount = rawAmount * ( 1 - mitigationFactor );
	return mitigatedAmount;
end



-- PUBLIC API

CombatComponent.init = function( self, entity )
	assert( entity );
	self._entity = entity;
	self._health = Stat:new( 500, 0, nil );
	self._defense = Stat:new( 10, 1, nil );
	self._strength = Stat:new( 10, 1, nil );
	self._attackRating = Stat:new( 1.5, 0, nil );
	self._critRate = Stat:new( .02, 0, 1 );
	self._critRating = Stat:new( 2, 1, nil );
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
