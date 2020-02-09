require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local Sprite = require("engine/scene/display/Sprite");
local Hitbox = require("engine/scene/physics/Hitbox");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local HitboxSystem = Class("HitboxSystem", System);

HitboxSystem.init = function(self, ecs)
	HitboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Hitbox, PhysicsBody, Sprite});
	self:getECS():addQuery(self._query);
end

HitboxSystem.update = function(self, dt)
	for _, entity in self._query:getAddedEntities() do
		local body = entity:getComponent(PhysicsBody):getBody();
		local hitbox = entity:getComponent(Hitbox);
		local sprite = entity:getComponent(Sprite);
		local shape = sprite:getTagShape("hit");
		hitbox:setShape(body, shape);
	end

	for _, entity in self._query:getRemovedEntities() do
		local hitbox = entity:getComponent(Hitbox);
		hitbox:setShape(nil);
	end
end

return HitboxSystem;
