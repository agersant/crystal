require("engine/utils/OOP");
local TargetSelector = require("arpg/combat/ai/TargetSelector");
local CombatData = require("arpg/combat/CombatData");
local DamageComponent = require("arpg/combat/damage/DamageComponent");
local DamageHitbox = require("arpg/combat/damage/DamageHitbox");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local IdleAnimation = require("arpg/field/animation/IdleAnimation");
local WalkAnimation = require("arpg/field/animation/WalkAnimation");
local MovementAI = require("engine/mapscene/behavior/ai/movement/MovementAI");
local Entity = require("engine/ecs/Entity");
local Assets = require("engine/resources/Assets");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Collision = require("engine/mapscene/physics/Collision");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local Script = require("engine/script/Script");

local Sahagin = Class("Sahagin", Entity);

local attack = function(self)
	self:setMovementAngle(nil);
	self:setAnimation("attack_" .. self:getDirection4(), true);
	self:waitFor("animationEnd");
end

local reachAndAttack = function(self)
	self:endOn("disrupted");
	self:endOn("died");

	local entity = self:getEntity();
	local targetSelector = TargetSelector:new(entity:getScene());
	local target = targetSelector:getNearestEnemy(entity);
	if not target then
		self:waitFrame();
		return;
	end

	if not self:join(self:navigateToEntity(target, 30)) then
		return;
	end

	if not self:join(self:alignWithEntity(target, 2)) then
		return;
	end

	self:lookAt(target:getPosition());
	self:wait(0.2);
	self:lookAt(target:getPosition());

	local damageIntent = DamageIntent:new();
	damageIntent:addComponent(DamageComponent:new(10));
	self:setDamageIntent(damageIntent);

	if not self:isIdle() then
		return;
	end
	local actionThread = self:doAction(attack);
	if self:join(actionThread) then
		self:wait(.5 + 2 * math.random());
	end
end

local ai = function(self)
	while true do
		while not self:isIdle() do
			self:waitFor("idle");
		end
		if self:isDead() then
			break
		end
		local taskThread = self:thread(reachAndAttack);
		self:join(taskThread);
		self:waitFrame();
	end
end

local hitReactions = function(self)
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
					self:setAnimation("knockback_" .. self:getDirection4());
					self:wait(1);
				end);
			end
		end
	end);

	self:thread(function(self)
		while true do
			self:waitFor("died");
			self:stopAction();
			self:doAction(function(self)
				self:setAnimation("smashed");
				self:wait(2);
				self:despawn();
				self:waitFrame();
			end);
		end
	end);
end

-- PUBLIC API

Sahagin.init = function(self, scene)
	Sahagin.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/sahagin.lua");
	self:addComponent(Sprite:new(sheet));
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	self:addComponent(Locomotion:new());
	self:addComponent(MovementAI:new());
	self:addComponent(Collision:new(4));
	self:addComponent(CombatData:new());
	self:addComponent(DamageHitbox:new());
	self:addComponent(Weakbox:new());
	self:addComponent(ScriptRunner:new());
	self:addComponent(Actor:new());

	self:addComponent(IdleAnimation:new("idle"));
	self:addComponent(WalkAnimation:new("walk"));

	self:addScript(Script:new(ai));
	self:addScript(Script:new(hitReactions));
end

return Sahagin;
