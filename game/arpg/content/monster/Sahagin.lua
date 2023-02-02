require("engine/utils/OOP");
local TargetSelector = require("arpg/field/combat/ai/TargetSelector");
local CombatData = require("arpg/field/combat/CombatData");
local DamageUnit = require("arpg/field/combat/damage/DamageUnit");
local CombatHitbox = require("arpg/field/combat/CombatHitbox");
local DamageIntent = require("arpg/field/combat/damage/DamageIntent");
local Flinch = require("arpg/field/combat/hit-reactions/Flinch");
local FlinchEffect = require("arpg/field/combat/hit-reactions/FlinchEffect");
local HitBlink = require("arpg/field/combat/hit-reactions/HitBlink");
local FlinchAnimation = require("arpg/field/animation/FlinchAnimation");
local IdleAnimation = require("arpg/field/animation/IdleAnimation");
local WalkAnimation = require("arpg/field/animation/WalkAnimation");
local CommonShader = require("arpg/graphics/CommonShader");
local Navigation = require("engine/mapscene/behavior/ai/Navigation");
local Entity = require("engine/ecs/Entity");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local SpriteAnimator = require("engine/mapscene/display/SpriteAnimator");
local Collision = require("engine/mapscene/physics/Collision");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local Script = require("engine/script/Script");

local Sahagin = Class("Sahagin", Entity);

local attack = function(self)
	self:endOn("disrupted");
	self:setMovementAngle(nil);
	self:resetMultiHitTracking();
	local onHitEffects = { FlinchEffect:new() };
	self:setDamagePayload({ DamageUnit:new(10) }, onHitEffects);
	self:join(self:playAnimation("attack", self:getAngle4(), true));
end

local reachAndAttack = function(self)
	self:endOn("disrupted");
	self:endOn("died");

	local target = self:getNearestEnemy();
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

local handleDeath = function(self)
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
end

Sahagin.init = function(self, scene)
	Sahagin.super.init(self, scene);

	local sheet = ASSETS:getSpritesheet("arpg/assets/spritesheet/sahagin.lua");
	local sprite = self:addComponent(Sprite:new());
	self:addComponent(SpriteAnimator:new(sprite, sheet));
	self:addComponent(CommonShader:new());
	self:addComponent(FlinchAnimation:new("knockback"));
	self:addComponent(IdleAnimation:new("idle"));
	self:addComponent(WalkAnimation:new("walk"));

	self:addComponent(ScriptRunner:new());
	self:addComponent(Actor:new());

	local physicsBody = self:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	self:addComponent(Locomotion:new());
	self:addComponent(Navigation:new());
	self:addComponent(Collision:new(physicsBody, 4));

	self:addComponent(CombatData:new());
	self:addComponent(DamageIntent:new());
	self:addComponent(CombatHitbox:new(physicsBody));
	self:addComponent(Weakbox:new(physicsBody));
	self:addComponent(TargetSelector:new());

	self:addComponent(Flinch:new());
	self:addComponent(HitBlink:new());

	local ai = self:addScript(Script:new(ai));
	ai:addThread(handleDeath);
end

return Sahagin;
