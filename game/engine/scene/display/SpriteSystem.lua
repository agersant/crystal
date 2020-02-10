require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Sprite = require("engine/scene/display/Sprite");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local SpriteSystem = Class("SpriteSystem", System);

SpriteSystem.init = function(self, ecs)
	SpriteSystem.super.init(self, ecs);
	self._query = AllComponents:new({Sprite, PhysicsBody});
	self:getECS():addQuery(self._query);
end

SpriteSystem.update = function(self, dt)
	local ecs = self:getECS();

	local sprites = ecs:getAllComponents(Sprite);
	for _, sprite in ipairs(sprites) do
		sprite:update(dt);
	end

	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local physicsBody = entity:getComponent(PhysicsBody);
		local x, y = physicsBody:getPosition();
		entity:setSpritePosition(x, y);
		entity:setZOrder(y);
	end
end

return SpriteSystem;
