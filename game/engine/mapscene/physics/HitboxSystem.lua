require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Sprite = require("engine/mapscene/display/Sprite");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local HitboxSystem = Class("HitboxSystem", System);

HitboxSystem.init = function(self, ecs)
	HitboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Hitbox, PhysicsBody, Sprite});
	self:getECS():addQuery(self._query);
end

HitboxSystem.beforePhysics = function(self, dt)
	for entity in pairs(self._query:getRemovedEntities()) do
		local hitbox = entity:getComponent(Hitbox);
		hitbox:setShape(nil);
	end

	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local hitbox = entity:getComponent(Hitbox);
		local sprite = entity:getComponent(Sprite);
		local shape = sprite:getTagShape("hit");
		hitbox:setShape(body, shape);
	end
end

return HitboxSystem;