require( "src/utils/OOP" );
local CLI = require( "src/dev/cli/CLI" );
local Actions = require( "src/scene/Actions" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local Controller = require( "src/scene/controller/Controller" );

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
				self:doAction( Actions.walk );
			end
			if DevBotController._behavior == "attack" then
				self:doAction( Actions.attack );
			end
		end
		self:waitFrame();
	end
end



return DevBotController;
