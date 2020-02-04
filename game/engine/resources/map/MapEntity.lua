require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Entity = require("engine/scene/entity/Entity");

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
		local entity = class:new(scene, self._options);
		if entity:hasPhysicsBody() then
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
