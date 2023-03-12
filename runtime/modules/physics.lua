local bit = require("bit");

local Collider = require("modules/physics/Collider");
local Fixture = require("modules/physics/Fixture")
local Movement = require("modules/physics/Movement");
local Body = require("modules/physics/Body");
local PhysicsSystem = require("modules/physics/PhysicsSystem");
local Sensor = require("modules/physics/Sensor");

---@param fixture_categories string[]
local define_fixture_categories = function(categories)
	Fixture.all_categories = {};
	local i = 0;
	for category, _ in pairs(categories) do
		assert(type(category) == "string");
		assert(i < 16);
		Fixture.all_categories[category] = bit.lshift(1, i);
		i = i + 1;
	end
end

return {
	global_api = {
		Collider = Collider,
		Movement = Movement,
		Body = Body,
		PhysicsSystem = PhysicsSystem,
		Sensor = Sensor,
	},
	module_api = {
		-- TOOD remove this function, currently only used by CollisionMesh!
		category = function(name)
			assert(type(name) == "string");
			assert(Fixture.all_categories[name]);
			return Fixture.all_categories[name];
		end,
	},
	init = function()
		local categories = { level = true };
		for _, category in ipairs(crystal.conf.physics_categories) do
			categories[category] = true;
		end
		define_fixture_categories(categories);
	end,
}
