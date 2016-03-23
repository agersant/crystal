require( "src/utils/OOP" );
local Movement = require( "src/ai/movement/Movement" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local Controller = require( "src/scene/controller/Controller" );
local Entity = require( "src/scene/entity/Entity" );
local Actions = require( "src/scene/Actions" );

local Sahagin = Class( "Sahagin", Entity );
local SahaginController = Class( "SahaginController", Controller );



-- PUBLIC API

Sahagin.init = function( self, scene )
	Sahagin.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/sahagin.lua" );
	self:addSprite( Sprite:new( sheet ) );
	self:addPhysicsBody( "dynamic" );
	self:addLocomotion();
	self:addCollisionPhysics();
	self:addCombatComponent();
	self:setCollisionRadius( 4 );
	self:setUseSpriteHitboxData( true );
	
	self:addController( SahaginController:new( self ) );
end

SahaginController.init = function( self, entity )
	SahaginController.super.init( self, entity, self.run );
	self._targetSelector = entity:getScene():getTargetSelector();
end

SahaginController.reachAndAttack = function( self )
	local entity = self:getEntity();
	local target = self._targetSelector:getNearestEnemy( entity );
	if not target then
		return;
	end
	if Movement.walkToEntity( target, 40 )( self ) then
		if self:isIdle() then
			self:doAction( Actions.attack );
		end
	end
end

SahaginController.run = function( self )
	self._combatLogic = CombatLogic:new( self );
	while true do
		if not self:isTaskless() or not self:isIdle() then
			self:waitFrame();
		else
			self:doTask( self.reachAndAttack );
			self:wait( 1 );
		end
	end
end


return Sahagin;
