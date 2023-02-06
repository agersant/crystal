local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local Sprite = require("mapscene/display/Sprite");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local SpriteSystem = Class("SpriteSystem", System);

SpriteSystem.init = function(self, ecs)
	SpriteSystem.super.init(self, ecs);
	self._bodyQuery = AllComponents:new({ Sprite, PhysicsBody });
	self:getECS():addQuery(self._bodyQuery);
end

SpriteSystem.afterScripts = function(self, dt)
	local entities = self._bodyQuery:getEntities();
	for entity in pairs(entities) do
		local sprite = entity:getComponent(Sprite);
		local physicsBody = entity:getComponent(PhysicsBody);
		local x, y = physicsBody:getPosition();
		sprite:setSpritePosition(x, y - physicsBody:getAltitude());
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
