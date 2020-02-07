require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Entity = require("engine/ecs/Entity");

local MapEntity = Class("MapEntity");

-- PUBLIC API

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
		if entity.setPosition then
			assert(self._options.x);
			assert(self._options.y);
			entity:setPosition(self._options.x, self._options.y);
		end
	end, function(err)
		Log:error("Error spawning map entity of class '" .. tostring(self._class) .. "':\n" .. tostring(err));
		print(debug.traceback());
	end);
end

return MapEntity;
