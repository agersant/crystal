local SpriteAnimator = require("mapscene/display/SpriteAnimator");
local Hitbox = require("mapscene/physics/Hitbox");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local HitboxSystem = Class("HitboxSystem", crystal.System);

HitboxSystem.init = function(self, ecs)
	HitboxSystem.super.init(self, ecs);
	self._query = self:ecs():add_query({ Hitbox, PhysicsBody });
	self._withSpriteAnimator = self:ecs():add_query({ Hitbox, PhysicsBody, SpriteAnimator });
end

HitboxSystem.beforePhysics = function(self, dt)
	for hitbox in pairs(self._query:added_components(Hitbox)) do
		hitbox:setEnabled(true);
	end

	for hitbox in pairs(self._query:removed_components(Hitbox)) do
		hitbox:setEnabled(false);
	end

	local entities = self._withSpriteAnimator:entities();
	for entity in pairs(entities) do
		local animator = entity:component(SpriteAnimator);
		for hitbox in pairs(entity:components(Hitbox)) do
			local shape = animator:getTagShape("hit");
			hitbox:setShape(shape);
		end
	end
end

return HitboxSystem;
