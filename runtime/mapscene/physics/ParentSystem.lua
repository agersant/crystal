local AllComponents = require("ecs/query/AllComponents");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local Parent = require("mapscene/physics/Parent");

local ParentSystem = Class("ParentSystem", crystal.System);

ParentSystem.init = function(self, ecs)
	ParentSystem.super.init(self, ecs);
	self._query = AllComponents:new({ Parent, PhysicsBody });
	self:ecs():add_query(self._query);
end

ParentSystem.afterPhysics = function(self, dt)
	local entities = self._query:getEntities();
	-- TODO there is no ordering here. Nested parenting isn't guaranteed to put all descendants in the same spot
	for entity in pairs(entities) do
		local parent = entity:component(Parent):getParentEntity();
		local physicsBody = entity:component(PhysicsBody);
		local otherBody = parent:component(PhysicsBody);
		if otherBody then
			local x, y = otherBody:getPosition();
			physicsBody:setPosition(x, y);
		end
	end
end

return ParentSystem;
