require("engine/utils/OOP");
local IdleAnimation = require("arpg/field/animation/IdleAnimation");
local WalkAnimation = require("arpg/field/animation/WalkAnimation");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Actor = require("engine/mapscene/behavior/Actor");
local Sprite = require("engine/mapscene/display/Sprite");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local AnimationSelectionSystem = Class("AnimationSelectionSystem", System);

AnimationSelectionSystem.init = function(self, ecs)
	AnimationSelectionSystem.super.init(self, ecs);
	self._idles = AllComponents:new({Sprite, PhysicsBody, IdleAnimation});
	self._walks = AllComponents:new({Sprite, PhysicsBody, Locomotion, WalkAnimation});
	self:getECS():addQuery(self._idles);
	self:getECS():addQuery(self._walks);
end

AnimationSelectionSystem.afterScripts = function(self)

	local walkEntities = self._walks:getEntities();
	local idleEntities = self._idles:getEntities();

	-- WALK
	for entity in pairs(walkEntities) do
		local locomotion = entity:getComponent(Locomotion);
		if locomotion:getMovementAngle() then
			local actor = entity:getComponent(Actor);
			local walkAnimation = entity:getComponent(WalkAnimation);
			if not actor or actor:isIdle() then
				local animation = walkAnimation:getWalkAnimation();
				if animation then
					local sprite = entity:getComponent(Sprite);
					local physicsBody = entity:getComponent(PhysicsBody);
					-- TODO introduce the concept of directions in Tiger and let the sheet figure out the best direction for our movement angle
					sprite:setAnimation(animation .. "_" .. physicsBody:getDirection4());
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
				local sprite = entity:getComponent(Sprite);
				local physicsBody = entity:getComponent(PhysicsBody);
				-- TODO introduce the concept of directions in Tiger and let the sheet figure out the best direction for our angle
				sprite:setAnimation(animation .. "_" .. physicsBody:getDirection4());
			end
		end
	end

end

return AnimationSelectionSystem;