require("engine/utils/OOP");
local FlinchAnimation = require("arpg/field/animation/FlinchAnimation");
local IdleAnimation = require("arpg/field/animation/IdleAnimation");
local WalkAnimation = require("arpg/field/animation/WalkAnimation");
local Flinch = require("arpg/field/combat/hit-reactions/Flinch");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Actor = require("engine/mapscene/behavior/Actor");
local SpriteAnimator = require("engine/mapscene/display/SpriteAnimator");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local AnimationSelectionSystem = Class("AnimationSelectionSystem", System);

AnimationSelectionSystem.init = function(self, ecs)
	AnimationSelectionSystem.super.init(self, ecs);
	self._idles = AllComponents:new({ SpriteAnimator, PhysicsBody, IdleAnimation });
	self._walks = AllComponents:new({ SpriteAnimator, PhysicsBody, Locomotion, WalkAnimation });
	self._flinches = AllComponents:new({ SpriteAnimator, PhysicsBody, Flinch, FlinchAnimation });
	self:getECS():addQuery(self._idles);
	self:getECS():addQuery(self._walks);
	self:getECS():addQuery(self._flinches);
end

AnimationSelectionSystem.afterScripts = function(self)

	local walkEntities = self._walks:getEntities();
	local idleEntities = self._idles:getEntities();
	local flinchEntities = self._flinches:getEntities();

	-- FLINCH
	for entity in pairs(flinchEntities) do
		local flinch = entity:getComponent(Flinch);
		if flinch:getFlinchAmount() then
			local flinchAnimation = entity:getComponent(FlinchAnimation);
			local animation = flinchAnimation:getFlinchAnimation();
			if animation then
				local animator = entity:getComponent(SpriteAnimator);
				local physicsBody = entity:getComponent(PhysicsBody);
				animator:setAnimation(animation, physicsBody:getAngle4());
				walkEntities[entity] = nil;
				idleEntities[entity] = nil;
			end
		end
	end

	-- WALK
	for entity in pairs(walkEntities) do
		local locomotion = entity:getComponent(Locomotion);
		if locomotion:getMovementAngle() then
			local actor = entity:getComponent(Actor);
			local walkAnimation = entity:getComponent(WalkAnimation);
			if not actor or actor:isIdle() then
				local animation = walkAnimation:getWalkAnimation();
				if animation then
					local animator = entity:getComponent(SpriteAnimator);
					local physicsBody = entity:getComponent(PhysicsBody);
					animator:setAnimation(animation, physicsBody:getAngle4());
					idleEntities[entity] = nil;
				end
			end
		end
	end

	-- IDLE
	for entity in pairs(idleEntities) do
		local actor = entity:getComponent(Actor);
		local idleAnimation = entity:getComponent(IdleAnimation);
		if not actor or actor:isIdle() then
			local animation = idleAnimation:getIdleAnimation();
			if animation then
				local animator = entity:getComponent(SpriteAnimator);
				local physicsBody = entity:getComponent(PhysicsBody);
				animator:setAnimation(animation, physicsBody:getAngle4());
			end
		end
	end

end

return AnimationSelectionSystem;
