require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local Actions = require("engine/scene/Actions");
local Movement = require("engine/ai/movement/Movement");
local CombatLogic = require("engine/scene/combat/CombatLogic");
local Controller = require("engine/scene/behavior/Controller");
local MathUtils = require("engine/utils/MathUtils");

local DevBotController = Class("DevBotController", Controller);

-- COMMANDS

DevBotController._behavior = "idle";
local setDevBotBehavior = function(behavior)
	DevBotController._behavior = behavior;
end

CLI:addCommand("setDevBotBehavior behavior:string", setDevBotBehavior);

-- PUBLIC API

DevBotController.init = function(self, entity)
	DevBotController.super.init(self, entity, self.run);
end

-- TODO: fix me

DevBotController.run = function(self)
	self._combatLogic = CombatLogic:new(self:getController());
	local entity = self:getEntity();
	while true do
		if self:isIdle() then
			if DevBotController._behavior == "idle" then
				self:doAction(Actions.idle);
			end
			if DevBotController._behavior == "walk" then
				self:doAction(Actions.walk(entity:getAngle()));
			end
			if DevBotController._behavior == "circle" then
				local circleDuration = 4;
				local t = (self._time % circleDuration) / circleDuration;
				local angle = t * 2 * math.pi;
				self:doAction(Actions.walk(angle));
			end
			if DevBotController._behavior == "attack" then
				self:doAction(Actions.attack);
			end
		end
		if self:isTaskless() then
			if DevBotController._behavior == "walkToPoint" then
				self:doTask(Movement.walkToPoint(32, 200, 6));
			end
			if DevBotController._behavior == "follow" then
				local player = entity:getScene():getPartyMemberEntities()[1];
				assert(player);
				self:doTask(Movement.walkToEntity(player, 40));
			end
		end
		self:waitFrame();
	end
end

return DevBotController;