require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local SpriteAnimator = require("engine/mapscene/display/SpriteAnimator");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local HitboxSystem = Class("HitboxSystem", System);

HitboxSystem.init = function(self, ecs)
	HitboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Hitbox, PhysicsBody});
	self._withSpriteAnimator = AllComponents:new({Hitbox, PhysicsBody, SpriteAnimator});
	self:getECS():addQuery(self._query);
	self:getECS():addQuery(self._withSpriteAnimator);
end

HitboxSystem.beforePhysics = function(self, dt)
	for hitbox in pairs(self._query:getAddedComponents(Hitbox)) do
		hitbox:setEnabled(true);
	end

	for hitbox in pairs(self._query:getRemovedComponents(Hitbox)) do
		hitbox:setEnabled(false);
	end

	local entities = self._withSpriteAnimator:getEntities();
	for entity in pairs(entities) do
		local animator = entity:getComponent(SpriteAnimator);
		for hitbox in pairs(entity:getComponents(Hitbox)) do
			local shape = animator:getTagShape("hit");
			hitbox:setShape(shape);
		end
	end
end

return HitboxSystem;
