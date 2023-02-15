local AllComponents = require("ecs/query/AllComponents");
local Sprite = require("mapscene/display/Sprite");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local SpriteSystem = Class("SpriteSystem", crystal.System);

SpriteSystem.init = function(self, ecs)
	SpriteSystem.super.init(self, ecs);
	self._bodyQuery = AllComponents:new({ Sprite, PhysicsBody });
	self:ecs():add_query(self._bodyQuery);
end

SpriteSystem.afterScripts = function(self, dt)
	local entities = self._bodyQuery:getEntities();
	for entity in pairs(entities) do
		local sprite = entity:component(Sprite);
		local physicsBody = entity:component(PhysicsBody);
		local x, y = physicsBody:getPosition();
		sprite:setSpritePosition(x, y - physicsBody:getAltitude());
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
