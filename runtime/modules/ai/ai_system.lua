---@class AISystem : System
---@field private map Map
---@field private query Query
local AISystem = Class("AISystem", crystal.System);

AISystem.init = function(self, map)
	assert(map:inherits_from(crystal.Map));
	self.map = map;
	self.query = self:add_query({ "Navigation" });
end

---@param dt number
AISystem.update_ai = function(self, dt)
	for navigation in pairs(self.query:components()) do
		navigation:update_navigation(dt);
	end
end

local draw_navigation = false;
crystal.cmd.add("showNavigationOverlay", function() draw_navigation = true; end);
crystal.cmd.add("hideNavigationOverlay", function() draw_navigation = false; end);

AISystem.draw_debug = function(self)
	if draw_navigation then
		self:draw_navigation_mesh();
		self:draw_paths();
	end
end

---@private
AISystem.draw_navigation_mesh = function(self)
	local line_color = crystal.Color.lavender_rose;
	local fill_color = line_color:alpha(.25);

	love.graphics.push("all");
	love.graphics.setLineWidth(1);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(4 * crystal.window.viewport_scale());

	local triangles = {};
	for _, t in ipairs(self.map:navigation_polygons()) do
		local vertices = { t[1][1], t[1][2], t[2][1], t[2][2], t[3][1], t[3][2] };
		love.graphics.setColor(fill_color);
		love.graphics.polygon("fill", vertices);

		love.graphics.setColor(line_color);
		love.graphics.polygon("line", vertices);
		love.graphics.points(vertices);
	end

	love.graphics.pop();
end

---@private
AISystem.draw_paths = function(self)
	love.graphics.push("all");
	love.graphics.setLineWidth(2);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(6 * crystal.window.viewport_scale());
	love.graphics.setColor(crystal.Color.bara_red);
	for navigation in pairs(self.query:components()) do
		local path, index = navigation:navigation_state();
		if path then
			local x, y = navigation:entity():position();
			love.graphics.line(x, y, path[index][1], path[index][2]);

			local points = {};
			for i = index, #path do
				table.push(points, path[i][1]);
				table.push(points, path[i][2]);
			end
			if #points >= 4 then
				love.graphics.line(points);
			end
			if #points >= 2 then
				table.push(points, x);
				table.push(points, y);
				love.graphics.points(points);
			end
		end
	end
	love.graphics.pop();
end

--#region Tests

local TestWorld = Class:test("TestWorld");

TestWorld.init = function(self)
	self.ecs = crystal.ECS:new();
	self.map = crystal.assets.get("test-data/empty.lua");
	self.ai_system = self.ecs:add_system(crystal.AISystem, self.map);
	self.physics_system = self.ecs:add_system(crystal.PhysicsSystem);
	self.script_system = self.ecs:add_system(crystal.ScriptSystem);
	self.map:spawn_entities(self.ecs);
end

TestWorld.update = function(self, dt)
	self.ecs:update(dt);
	self.ai_system:update_ai(dt);
	self.physics_system:simulate_physics(dt);
	self.script_system:run_scripts(dt);
end

TestWorld.draw = function(self)
	self.ecs:notify_systems("draw_debug");
end

crystal.test.add("Can draw navigation debug overlay", function()
	local world = TestWorld:new();
	crystal.cmd.run("showNavmeshOverlay");
	world:update(0);
	world:draw();
	crystal.cmd.run("hideNavmeshOverlay");
end);

crystal.test.add("Can walk to point", function()
	local world = TestWorld:new();

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local subject = world.ecs:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(crystal.Navigation, world.map);
	subject:add_component(crystal.ScriptRunner);

	subject:navigate_to(end_x, end_y, acceptance_radius);

	for i = 1, 1000 do
		world:update(16 / 1000);
	end
	assert(subject:distance_to(end_x, end_y) < acceptance_radius);
end);

crystal.test.add("Can walk to entity", function()
	local world = TestWorld:new();

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local subject = world.ecs:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(crystal.Navigation, world.map);
	subject:add_component(crystal.ScriptRunner);

	local target = world.ecs:spawn(crystal.Entity);
	target:add_component(crystal.Body);
	target:set_position(end_x, end_y);

	subject:navigate_to_entity(target, acceptance_radius);

	for i = 1, 1000 do
		world:update(16 / 1000);
	end
	assert(subject:distance_to_entity(target) < acceptance_radius);
end);

crystal.test.add("Can block on navigation thread", function()
	local world = TestWorld:new();

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local sentinel = false;

	local subject = world.ecs:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(crystal.Navigation, world.map);

	subject:add_component(crystal.ScriptRunner);
	subject:add_script(function(self)
		local success = self:navigate_to(end_x, end_y, acceptance_radius):block();
		sentinel = success;
	end);

	for i = 1, 10 do
		world:update(16 / 1000);
	end
	assert(not sentinel);
	for i = 1, 1000 do
		world:update(16 / 1000);
	end
	assert(subject:distance_to(end_x, end_y) < acceptance_radius);
	assert(sentinel);
end);

--#endregion

return AISystem;
