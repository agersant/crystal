require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Sprite = require("engine/mapscene/display/Sprite");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local WeakboxSystem = Class("WeakboxSystem", System);

WeakboxSystem.init = function(self, ecs)
	WeakboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Weakbox, PhysicsBody});
	self._withSprite = AllComponents:new({Weakbox, PhysicsBody, Sprite});
	self:getECS():addQuery(self._query);
	self:getECS():addQuery(self._withSprite);
end

WeakboxSystem.beforePhysics = function(self, dt)
	for weakbox in pairs(self._query:getRemovedComponents(Weakbox)) do
		weakbox:clearShape();
	end

	local entities = self._withSprite:getEntities();
	for entity in pairs(entities) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local weakbox = entity:getComponent(Weakbox);
		local sprite = entity:getComponent(Sprite);
		local shape = sprite:getTagShape("weak");
		if shape then
			weakbox:setShape(body, shape);
		else
			weakbox:clearShape();
		end
	end
end

return WeakboxSystem;
