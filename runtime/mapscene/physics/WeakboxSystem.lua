local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local SpriteAnimator = require("mapscene/display/SpriteAnimator");
local Weakbox = require("mapscene/physics/Weakbox");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local WeakboxSystem = Class("WeakboxSystem", System);

WeakboxSystem.init = function(self, ecs)
	WeakboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({ Weakbox, PhysicsBody });
	self._withSpriteAnimator = AllComponents:new({ Weakbox, PhysicsBody, SpriteAnimator });
	self:getECS():addQuery(self._query);
	self:getECS():addQuery(self._withSpriteAnimator);
end

WeakboxSystem.beforePhysics = function(self, dt)
	for weakbox in pairs(self._query:getAddedComponents(Weakbox)) do
		weakbox:setEnabled(true);
	end

	for weakbox in pairs(self._query:getRemovedComponents(Weakbox)) do
		weakbox:setEnabled(false);
	end

	local entities = self._withSpriteAnimator:getEntities();
	for entity in pairs(entities) do
		local animator = entity:getComponent(SpriteAnimator);
		for weakbox in pairs(entity:getComponents(Weakbox)) do
			local shape = animator:getTagShape("weak");
			weakbox:setShape(shape);
		end
	end
end

return WeakboxSystem;
