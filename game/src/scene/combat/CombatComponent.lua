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



-- PUBLIC API

CombatComponent.init = function( self, entity )
	assert( entity );
	self:setTeam( Teams.wild );
	self._entity = entity;
	self._health = Stat:new( 500, 0, nil );
	self._defense = Stat:new( 10, 1, nil );
	self._strength = Stat:new( 10, 1, nil );
	self._attackRating = Stat:new( 1.5, 0, nil );
	self._critRate = Stat:new( .02, 0, 1 );
	self._critRating = Stat:new( 2, 1, nil );
	self._skills = {};
end

CombatComponent.setTeam = function( self, team )
	assert( Teams:isValid( team ) );
	self._team = team;
end

CombatComponent.getTeam = function( self )
	return self._team;
end

CombatComponent.addSkill = function( self, skill )
	table.insert( self._skills, skill );	
end

CombatComponent.setSkill = function( self, index, skill )
	assert( index > 0 );
	local oldSkill = self:getSkill( index );
	if oldSkill then
		oldSkill:cleanup();
	end
	self._skills[index] = skill;
end

CombatComponent.getSkill = function( self, index )
	assert( index > 0 );
	return self._skills[index];
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
