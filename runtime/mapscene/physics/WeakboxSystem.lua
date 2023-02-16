local SpriteAnimator = require("mapscene/display/SpriteAnimator");
local Weakbox = require("mapscene/physics/Weakbox");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local WeakboxSystem = Class("WeakboxSystem", crystal.System);

WeakboxSystem.init = function(self, ecs)
	WeakboxSystem.super.init(self, ecs);
	self._query = self:ecs():add_query({ Weakbox, PhysicsBody });
	self._withSpriteAnimator = self:ecs():add_query({ Weakbox, PhysicsBody, SpriteAnimator });
end

WeakboxSystem.beforePhysics = function(self, dt)
	for weakbox in pairs(self._query:added_components(Weakbox)) do
		weakbox:setEnabled(true);
	end

	for weakbox in pairs(self._query:removed_components(Weakbox)) do
		weakbox:setEnabled(false);
	end

	local entities = self._withSpriteAnimator:entities();
	for entity in pairs(entities) do
		local animator = entity:component(SpriteAnimator);
		for weakbox in pairs(entity:components(Weakbox)) do
			local shape = animator:getTagShape("weak");
			weakbox:setShape(shape);
		end
	end
end

return WeakboxSystem;
