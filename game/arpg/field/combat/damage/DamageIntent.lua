require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local DamageIntent = Class("DamageIntent", Component);

DamageIntent.init = function(self)
	DamageIntent.super.init(self);
	self._units = {};
end

DamageIntent.setDamageUnits = function(self, units)
	assert(type(units) == "table");
	self._units = units;
end

DamageIntent.getDamageUnits = function(self)
	local units = {};
	for _, u in ipairs(self._units) do
		units[u] = true;
	end
	return units;
end

return DamageIntent;
