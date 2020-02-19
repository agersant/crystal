local Stats = require("arpg/field/combat/stats/Stats");
local TableUtils = require("engine/utils/TableUtils");

local ScalingSources = {};

for name, value in pairs(Stats) do
	ScalingSources[name] = value;
end

local nextIndex = TableUtils.countKeys(Stats) + 1;

ScalingSources.MISSING_HEALTH = nextIndex;
nextIndex = nextIndex + 1;

return ScalingSources;
