require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");

local DamageIntent = Class("DamageIntent");

-- PUBLIC API

DamageIntent.init = function(self)
	self._components = {};
end

DamageIntent.addComponent = function(self, component)
	self._components[component] = true;
end

DamageIntent.getComponents = function(self)
	return TableUtils.shallowCopy(self._components);
end

return DamageIntent;
