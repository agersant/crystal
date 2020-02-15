require("engine/utils/OOP");
local TargetSelector = require("arpg/combat/ai/TargetSelector");
local CombatData = require("arpg/combat/CombatData");
local DamageComponent = require("arpg/combat/damage/DamageComponent");
local DamageHitbox = require("arpg/combat/damage/DamageHitbox");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local Movement = require("engine/mapscene/behavior/ai/movement/Movement");
local Entity = require("engine/ecs/Entity");
local Assets = require("engine/resources/Assets");
local Actions = require("engine/mapscene/Actions");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Collision = require("engine/mapscene/physics/Collision");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local Script = require("engine/script/Script");

local Sahagin = Class("Sahagin", Entity);

local reachAndAttack = function(self)
	self:endOn("disrupted");
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

					local damageIntent = DamageIntent:new();
					damageIntent:addComponent(DamageComponent:new(1));
					self:setDamageIntent(damageIntent);

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

local aiScript = function(self)

	self:thread(function(self)
		while true do
			self:waitFor("disrupted");
			self:stopAction();
		end
	end);

	self:thread(function(self)
		while true do
			self:waitFor("receivedDamage");
			if self:isIdle() then
				self:doAction(function(self)
					self:setSpeed(0);
					self:setDesiredAnimation("knockback_" .. self:getDirection4());
					self:wait(1);
				end);
			end
		end
	end);

	while true do
		while not self:isIdle() do
			self:waitFor("idle");
		end
		local taskThread = self:thread(reachAndAttack);
		self:join(taskThread);
	end
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
	self:addComponent(Actor:new());

	self:addScript(Script:new(aiScript));
end

return Sahagin;
