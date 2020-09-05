require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Sprite = require("engine/mapscene/display/Sprite");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local HitboxSystem = Class("HitboxSystem", System);

HitboxSystem.init = function(self, ecs)
	HitboxSystem.super.init(self, ecs);
	self._query = AllComponents:new({Hitbox, PhysicsBody});
	self._withSprite = AllComponents:new({Hitbox, PhysicsBody, Sprite});
	self:getECS():addQuery(self._query);
	self:getECS():addQuery(self._withSprite);
end

HitboxSystem.beforePhysics = function(self, dt)
	for hitbox in pairs(self._query:getRemovedComponents(Hitbox)) do
		hitbox:clearShape();
	end

	local entities = self._withSprite:getEntities();
	for entity in pairs(entities) do
		local body = entity:getComponent(PhysicsBody):getBody();
		local hitbox = entity:getComponent(Hitbox);
		local sprite = entity:getComponent(Sprite);
		local shape = sprite:getTagShape("hit");
		if shape then
			hitbox:setShape(body, shape);
		else
			hitbox:clearShape();
		end
	end
end

return HitboxSystem;
