local bit = require("bit");

local Collider = require("modules/physics/collider");
local Fixture = require("modules/physics/fixture")
local Movement = require("modules/physics/movement");
local Body = require("modules/physics/body");
local PhysicsSystem = require("modules/physics/physics_system");
local Sensor = require("modules/physics/sensor");

return {
	module_api = {
		define_categories = function(user_categories)
			local categories = table.copy(user_categories);
			table.push(categories, "level");
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
