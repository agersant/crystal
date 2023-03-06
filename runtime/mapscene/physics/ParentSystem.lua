local Parent = require("mapscene/physics/Parent");

local ParentSystem = Class("ParentSystem", crystal.System);

ParentSystem.init = function(self)
	self._query = self:add_query({ Parent, crystal.PhysicsBody });
end

ParentSystem.after_physics = function(self, dt)
	local entities = self._query:entities();
	-- TODO there is no ordering here. Nested parenting isn't guaranteed to put all descendants in the same spot
	for entity in pairs(entities) do
		local parent = entity:component(Parent):getParentEntity();
		local physics_body = entity:component(crystal.PhysicsBody);
		local otherBody = parent:component(crystal.PhysicsBody);
		if otherBody then
			local x, y = otherBody:position();
			physics_body:set_position(x, y);
		end
	end
end

return ParentSystem;
