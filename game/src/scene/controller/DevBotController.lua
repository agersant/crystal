require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Actions = require( "src/scene/Actions" );
local Movement = require( "src/ai/movement/Movement" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local Controller = require( "src/scene/controller/Controller" );
local MathUtils = require( "src/utils/MathUtils" );

local DevBotController = Class( "DevBotController", Controller );



-- COMMANDS

DevBotController._behavior = "idle";
local setDevBotBehavior = function( behavior )
	DevBotController._behavior = behavior;
end

CLI:addCommand( "setDevBotBehavior behavior:string", setDevBotBehavior );



-- PUBLIC API

DevBotController.init = function( self, entity )
	DevBotController.super.init( self, entity, self.run );
end

DevBotController.run = function( self )
	self._combatLogic = CombatLogic:new( self );
	local entity = self:getEntity();
	while true do
		if self:isIdle() then
			if DevBotController._behavior == "idle" then
				self:doAction( Actions.idle );
			end
			if DevBotController._behavior == "walk" then
				self:doAction( Actions.walk( entity:getAngle() ) );
			end
			if DevBotController._behavior == "circle" then
				local circleDuration = 4;
				local t = ( self._time % circleDuration ) / circleDuration;
				local angle = t * 2 * math.pi;
				self:doAction( Actions.walk( angle ) );
			end
			if DevBotController._behavior == "attack" then
				self:doAction( Actions.attack );
			end
		end
		if self:isTaskless() then
			if DevBotController._behavior == "walkToPoint" then
				self:doTask( Movement.walkToPoint( 32, 200, 6 ) );
			end
			if DevBotController._behavior == "follow" then
				-- TODO TMP
				self:doTask( Movement.walkToEntity( entity:getScene():getPlayer(), 40 ) );
			end
		end
		self:waitFrame();
	end
end



return DevBotController;
