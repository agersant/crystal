local PhysicsBody = require("mapscene/physics/PhysicsBody");

local MapEntity = Class("MapEntity");

MapEntity.init = function(self, class, options)
	assert(type(class) == "string");
	assert(type(options) == "table");
	self._class = class;
	self._options = options;
end

MapEntity.spawn = function(self, scene)
	xpcall(function()
		local entity = scene:spawn(self._class, self._options);
		local physicsBody = entity:component(PhysicsBody);
		if physicsBody then
			assert(self._options.x);
			assert(self._options.y);
			physicsBody:setPosition(self._options.x, self._options.y);
		end
	end, function(err)
		crystal.log.error("Error spawning map entity of class '" .. tostring(self._class) .. "':\n" .. tostring(err));
		print(debug.traceback());
	end);
end

return MapEntity;
