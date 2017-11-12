require( "src/utils/OOP" );
local Stat = require( "src/combat/Stat" );
local Damage = require( "src/combat/Damage" );
local Teams = require( "src/combat/Teams" );

local CombatData = Class( "CombatData" );



-- IMPLEMENTATION

local mitigateDamage = function( self, damage )
	local rawAmount = damage:getAmount();
	local defense = self._defense:getValue();
	local mitigationFactor = defense / ( defense + 100 );
	local mitigatedAmount = rawAmount * ( 1 - mitigationFactor );
	return math.ceil( mitigatedAmount );
end



-- PUBLIC API

CombatData.init = function( self, entity )
	assert( entity );
	self:setTeam( Teams.wild );
	self._entity = entity;
	self._health = Stat:new( 50, 0, nil );
	self._defense = Stat:new( 10, 1, nil );
	self._strength = Stat:new( 10, 1, nil );
	self._attackRating = Stat:new( 1.5, 0, nil );
	self._critRate = Stat:new( .02, 0, 1 );
	self._critRating = Stat:new( 2, 1, nil );
	self._skills = {};
end

CombatData.setTeam = function( self, team )
	assert( Teams:isValid( team ) );
	self._team = team;
end

CombatData.getTeam = function( self )
	return self._team;
end

CombatData.addSkill = function( self, skill )
	self:setSkill( 1 + #self._skills, skill );
end

CombatData.setSkill = function( self, index, skill )
	assert( index > 0 );
	local oldSkill = self:getSkill( index );
	if oldSkill then
		self._entity:removeScript( oldSkill );
	end
	self._skills[index] = skill;
	self._entity:addScript( skill );
end

CombatData.getSkill = function( self, index )
	assert( index > 0 );
	return self._skills[index];
end

CombatData.inflictDamageTo = function( self, target )
	local effectiveStrength = self._strength:getValue() * self._attackRating:getValue();
	local isCrit = math.random() < self._critRate:getValue();
	if isCrit then
		effectiveStrength = effectiveStrength * self._critRating:getValue();
	end
	local damage = Damage:new( effectiveStrength, self._entity );
	target:receiveDamage( damage );
end

CombatData.receiveDamage = function( self, damage )
	if self:isDead() then
		return;
	end
	local effectiveDamage = mitigateDamage( self, damage );
	self._health:substract( effectiveDamage );
	self._entity:signal( "takeHit", damage, effectiveDamage );
	if self:isDead() then
		self._entity:signal( "death" );
	end
end

CombatData.isDead = function( self )
	return self._health:getValue() == 0;
end



return CombatData;
