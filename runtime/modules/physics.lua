local bit = require("bit");

local Collider = require("modules/physics/Collider");
local Movement = require("modules/physics/Movement");
local PhysicsBody = require("modules/physics/PhysicsBody");
local PhysicsSystem = require("modules/physics/PhysicsSystem");
local Sensor = require("modules/physics/Sensor");

---@param fixture_categories string[]
local define_fixture_categories = function(categories)
	crystal.physics.categories = {};
	local i = 0;
	for category, _ in pairs(categories) do
		assert(type(category) == "string");
		assert(i < 16);
		crystal.physics.categories[category] = bit.lshift(1, i);
		i = i + 1;
	end
end

return {
	global_api = {
		Collider = Collider,
		Movement = Movement,
		PhysicsBody = PhysicsBody,
		PhysicsSystem = PhysicsSystem,
		Sensor = Sensor,
	},
	module_api = {
		category = function(name)
			assert(type(name) == "string");
			assert(crystal.physics.categories[name]);
			return crystal.physics.categories[name];
		end,
	},
	init = function()
		local categories = { level = true };
		for _, category in ipairs(crystal.conf.physicsCategories) do
			categories[category] = true;
		end
		define_fixture_categories(categories);
	end,
}
