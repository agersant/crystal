require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Sprite = require("engine/scene/display/Sprite");
local Weakbox = require("engine/scene/physics/Weakbox");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local WeakboxSystem = Class("WeakboxSystem", System);

WeakboxSystem.init = function(self, ecs)
	WeakboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Weakbox, PhysicsBody, Sprite});
	self:getECS():addQuery(self._query);
end

WeakboxSystem.update = function(self, dt)
	for entity in pairs(self._query:getRemovedEntities()) do
		local weakbox = entity:getComponent(Weakbox);
		weakbox:setShape(nil);
	end

	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local weakbox = entity:getComponent(Weakbox);
		local sprite = entity:getComponent(Sprite);
		local shape = sprite:getTagShape("weak");
		weakbox:setShape(body, shape);
	end
end

return WeakboxSystem;
