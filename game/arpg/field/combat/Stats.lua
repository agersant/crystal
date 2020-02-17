local DamageTypes = require("arpg/field/combat/damage/DamageTypes");
local Elements = require("arpg/field/combat/damage/Elements");
local TableUtils = require("engine/utils/TableUtils");

local Stats = {HEALTH = 1, MOVEMENT_SPEED = 2};

local nextIndex = TableUtils.countKeys(Stats) + 1;
for name in pairs(DamageTypes) do
	Stats["OFFENSE_" .. name] = nextIndex;
	Stats["DEFENSE_" .. name] = nextIndex + 1;
	nextIndex = nextIndex + 2;
end

local nextIndex = TableUtils.countKeys(Stats) + 1;
for name in pairs(Elements) do
	Stats["AFFINITY_" .. name] = nextIndex;
	Stats["RESISTANCE_" .. name] = nextIndex + 1;
	nextIndex = nextIndex + 2;
end

return Stats;
