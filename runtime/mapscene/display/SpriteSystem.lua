local Sprite = require("mapscene/display/Sprite");

local SpriteSystem = Class("SpriteSystem", crystal.System);

SpriteSystem.init = function(self)
	self._query = self:add_query({ Sprite, crystal.PhysicsBody });
end

SpriteSystem.after_run_scripts = function(self, dt)
	local entities = self._query:entities();
	for entity in pairs(entities) do
		local sprite = entity:component(Sprite);
		local physics_body = entity:component(crystal.PhysicsBody);
		local x, y = physics_body:position();
		sprite:setSpritePosition(x, y);
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
