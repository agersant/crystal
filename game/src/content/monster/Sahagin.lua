require( "src/utils/OOP" );
local Movement = require( "src/ai/movement/Movement" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local Controller = require( "src/scene/controller/Controller" );
local Script = require( "src/scene/controller/Script" );
local Entity = require( "src/scene/entity/Entity" );
local Actions = require( "src/scene/Actions" );

local Sahagin = Class( "Sahagin", Entity );
local SahaginController = Class( "SahaginController", Controller );



local reachAndAttack = function( self )	
	local controller = self:getController();
	local entity = controller:getEntity();
	local targetSelector = entity:getScene():getTargetSelector();
	local target = targetSelector:getNearestEnemy( entity );
	if not target then
		return;
	end
	if Movement.walkToEntity( target, 40 )( self ) then
		if controller:isIdle() then
			Movement.alignWithEntity( entity, target, 2 )( self );
			if controller:isIdle() then
				Actions.lookAt( target )( self );
				controller:doAction( Actions.attack );
			end
		end
	end
end

local controllerScript = function( self )
	local controller = self:getController();
	while true do
		if not controller:isTaskless() or not controller:isIdle() then
			self:waitFrame();
		else
			controller:doTask( reachAndAttack );
			self:wait( 1 );
		end
	end
end

SahaginController.init = function( self, entity )
	SahaginController.super.init( self, entity );
	self:addScript( CombatLogic:new( self ) );
	self:addScript( Script:new( self, controllerScript ) );
end



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



return Sahagin;
