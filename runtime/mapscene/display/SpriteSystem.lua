local Sprite = require("mapscene/display/Sprite");

local SpriteSystem = Class("SpriteSystem", crystal.System);

SpriteSystem.init = function(self)
	self._query = self:add_query({ Sprite, crystal.Body });
end

SpriteSystem.after_run_scripts = function(self, dt)
	local entities = self._query:entities();
	for entity in pairs(entities) do
		local sprite = entity:component(Sprite);
		local body = entity:component(crystal.Body);
		local x, y = body:position();
		sprite:setSpritePosition(x, y);
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
