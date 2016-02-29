require( "src/utils/OOP" );
local CombatStat = require( "src/scene/combat/CombatStat" );
local Damage = require( "src/scene/combat/Damage" );

local CombatComponent = Class( "CombatComponent" );



-- PUBLIC API

CombatComponent.init = function( self, entity )
	assert( entity );
	self._entity = entity;
	self._health = CombatStat:new( 40, 0, nil );
end

CombatComponent.inflictDamageTo = function( self, target )
	local damage = Damage:new( 10, self._entity ); -- TODO proper amount
	target:receiveDamage( damage );
end

CombatComponent.receiveDamage = function( self, damage )
	if self:isDead() then
		return;
	end
	self._entity:signal( "takeHit", damage );
	local amount = damage:getAmount();
	self._health:substract( amount );
	if self:isDead() then
		self._entity:signal( "death" );
	end
end

CombatComponent.isDead = function( self )
	return self._health:getValue() == 0;
end



return CombatComponent;
