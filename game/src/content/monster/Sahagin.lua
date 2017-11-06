require( "src/utils/OOP" );
local Movement = require( "src/ai/movement/Movement" );
local Assets = require( "src/resources/Assets" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );
local Controller = require( "src/scene/component/Controller" );
local Sprite = require( "src/scene/component/Sprite" );
local Entity = require( "src/scene/entity/Entity" );

local Sahagin = Class( "Sahagin", Entity );
local SahaginController = Class( "SahaginController", Controller );



local reachAndAttack = function( self )
	local entity = self:getEntity();
	local targetSelector = entity:getScene():getTargetSelector();
	local target = targetSelector:getNearestEnemy( entity );
	if not target then
		return;
	end
	if Movement.walkToEntity( target, 30 )( self ) then
		if self:isIdle() then
			Movement.alignWithEntity( entity, target, 2 )( self );
			if self:isIdle() then
				Actions.lookAt( target )( self );
				self:wait( .2 );
				if self:isIdle() then
					Actions.lookAt( target )( self );
					self:doAction( Actions.attack );
					self:waitFor( "idle" );
					if self:isIdle() then
						self:doAction( Actions.idle );
						self:wait( .5 + 2 * math.random() );
					end
				end
			end
		end
	end
end

local controllerScript = function( self )
	while true do
		if not self:isTaskless() or not self:isIdle() then
			self:waitFrame();
		else
			self:doTask( reachAndAttack );
		end
	end
end

SahaginController.init = function( self, entity )
	SahaginController.super.init( self, entity, controllerScript );
end



-- PUBLIC API

Sahagin.init = function( self, scene )
	Sahagin.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/sahagin.lua" );
	self:addSprite( Sprite:new( sheet ) );
	self:addPhysicsBody( "dynamic" );
	self:addLocomotion();
	self:setMovementSpeed( 40 );
	self:addCollisionPhysics();
	self:addCombatData();
	self:setCollisionRadius( 4 );
	self:setUseSpriteHitboxData( true );
	self:addScriptRunner();
	self:addCombatLogic();
	self:addController( SahaginController:new( self ) );
end



return Sahagin;
