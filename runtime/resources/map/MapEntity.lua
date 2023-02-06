local Entity = require("ecs/Entity");
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
		local class = Class:getByName(self._class);
		assert(class);
		assert(class:isInstanceOf(Entity));
		local entity = scene:spawn(class, self._options);
		local physicsBody = entity:getComponent(PhysicsBody);
		if physicsBody then
			assert(self._options.x);
			assert(self._options.y);
			physicsBody:setPosition(self._options.x, self._options.y);
		end
	end, function(err)
		LOG:error("Error spawning map entity of class '" .. tostring(self._class) .. "':\n" .. tostring(err));
		print(debug.traceback());
	end);
end

return MapEntity;
