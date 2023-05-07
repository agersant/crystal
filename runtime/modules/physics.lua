local bit = require("bit");

local Collider = require(CRYSTAL_RUNTIME .. "/modules/physics/collider");
local Fixture = require(CRYSTAL_RUNTIME .. "/modules/physics/fixture")
local Movement = require(CRYSTAL_RUNTIME .. "/modules/physics/movement");
local Body = require(CRYSTAL_RUNTIME .. "/modules/physics/body");
local PhysicsSystem = require(CRYSTAL_RUNTIME .. "/modules/physics/physics_system");
local Sensor = require(CRYSTAL_RUNTIME .. "/modules/physics/sensor");

return {
	module_api = {
		define_categories = function(user_categories)
			local categories = table.copy(user_categories);
			table.insert(categories, 1, "level");
			Fixture.all_categories = {};
			for i, category in ipairs(categories) do
				assert(type(category) == "string");
				assert(i < 16);
				Fixture.all_categories[category] = bit.lshift(1, i - 1);
			end
		end
	},
	global_api = {
		Collider = Collider,
		Movement = Movement,
		Body = Body,
		PhysicsSystem = PhysicsSystem,
		Sensor = Sensor,
	},
}
