require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");

local DamageIntent = Class("DamageIntent");

-- TODO make this a unit and remove DamageHitbox

-- PUBLIC API

DamageIntent.init = function(self)
	self._units = {};
end

DamageIntent.setUnits = function(self, units)
	assert(type(units) == "table");
	self._units = units;
end

DamageIntent.getUnits = function(self)
	local units = {};
	for _, u in ipairs(self._units) do
		units[u] = true;
	end
	return units;
end

return DamageIntent;
