require("engine/utils/OOP");
local TargetSelector = require("arpg/combat/ai/TargetSelector");
local CombatData = require("arpg/combat/CombatData");
local DamageHitbox = require("arpg/combat/DamageHitbox");
local Movement = require("engine/mapscene/behavior/ai/movement/Movement");
local Entity = require("engine/ecs/Entity");
local Assets = require("engine/resources/Assets");
local Actions = require("engine/mapscene/Actions");
local Controller = require("engine/mapscene/behavior/Controller");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Collision = require("engine/mapscene/physics/Collision");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Weakbox = require("engine/mapscene/physics/Weakbox");

local Sahagin = Class("Sahagin", Entity);
local SahaginController = Class("SahaginController", Controller);

local reachAndAttack = function(self)
	local entity = self:getEntity();
	local targetSelector = TargetSelector:new(entity:getScene());
	local target = targetSelector:getNearestEnemy(entity);
	if not target then
		self:waitFrame();
		return;
	end
	if Movement.walkToEntity(self, target, 30) then
		if self:isIdle() then
			Movement.alignWithEntity(self, target, 2);
			if self:isIdle() then
				Actions.lookAt(target)(self);
				self:wait(.2);
				if self:isIdle() then
					Actions.lookAt(target)(self);
					self:doAction(Actions.attack);
					self:waitFor("idle");
					if self:isIdle() then
						self:doAction(Actions.idle);
						self:wait(.5 + 2 * math.random());
					end
				end
			end
		end
	end
end

local controllerScript = function(self)
	while true do
		if not self:isTaskless() or not self:isIdle() then
			self:waitFrame();
		else
			self:doTask(reachAndAttack);
		end
	end
end

SahaginController.init = function(self)
	SahaginController.super.init(self, controllerScript);
end

-- PUBLIC API

Sahagin.init = function(self, scene)
	Sahagin.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/sahagin.lua");
	self:addComponent(Sprite:new(sheet));
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	self:addComponent(Locomotion:new());
	-- self:setMovementSpeed(40); TODO
	self:addComponent(Collision:new(4));
	self:addComponent(CombatData:new());
	self:addComponent(DamageHitbox:new());
	self:addComponent(Weakbox:new());
	self:addComponent(ScriptRunner:new());
	self:addComponent(SahaginController:new(self));
end

return Sahagin;
