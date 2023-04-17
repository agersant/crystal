local Fixture = require("modules/physics/fixture");

---@class PhysicsSystem : System
---@field private _world love.World
---@field private with_body Query
---@field private with_movement Query
---@field private with_fixture Query
---@field private contact_callbacks { func: fun(), args: table }[]
local PhysicsSystem = Class("PhysicsSystem", crystal.System);

PhysicsSystem.init = function(self)
	self._world = love.physics.newWorld();
	self.with_body = self:add_query({ "Body" });
	self.with_movement = self:add_query({ "Body", "Movement" });
	self.with_fixture = self:add_query({ "Body", "Fixture" });

	self.contact_callbacks = {};
	self._world:setCallbacks(
		function(...) self:begin_contact(...) end,
		function(...) self:end_contact(...) end
	);
end

---@return love.World
PhysicsSystem.world = function(self)
	return self._world;
end

---@param dt number # in seconds
PhysicsSystem.simulate_physics = function(self, dt)
	for body in pairs(self.with_body:added_components("Body")) do
		body:on_added();
	end

	for body in pairs(self.with_body:removed_components("Body")) do
		body:on_removed();
	end

	for fixture in pairs(self.with_fixture:added_components("Fixture")) do
		fixture:on_added();
	end

	for fixture in pairs(self.with_fixture:removed_components("Fixture")) do
		fixture:on_removed();
	end

	for entity in pairs(self.with_movement:entities()) do
		local movement = entity:component("Movement");
		local body = entity:component("Body");
		if movement:is_movement_enabled() then
			local speed = movement:speed();
			local heading = movement:heading();
			if heading then
				body:set_rotation(heading);
				local dx = math.cos(heading);
				local dy = math.sin(heading);
				body:set_velocity(speed * dx, speed * dy);
			else
				body:set_velocity(0, 0);
			end
		end
	end

	self._world:update(dt);
	for _, callback in ipairs(self.contact_callbacks) do
		callback.func(unpack(callback.args));
	end
	self.contact_callbacks = {};
end

---@param fixture_a Fixture
---@param fixture_b Fixture
---@param fixture_b love.Contact
PhysicsSystem.begin_contact = function(self, fixture_a, fixture_b, contact)
	local owner_a = fixture_a:getUserData();
	local owner_b = fixture_b:getUserData();
	if not owner_a or not owner_b then
		return;
	end
	if owner_a:inherits_from(Fixture) and owner_b:inherits_from(Fixture) then
		table.push(self.contact_callbacks, { func = owner_a.begin_contact, args = { owner_a, owner_b, contact } });
		table.push(self.contact_callbacks, { func = owner_b.begin_contact, args = { owner_b, owner_a, contact } });
	end
end

---@param fixture_a Fixture
---@param fixture_b Fixture
---@param fixture_b love.Contact
PhysicsSystem.end_contact = function(self, fixture_a, fixture_b, contact)
	local owner_a = fixture_a:getUserData();
	local owner_b = fixture_b:getUserData();
	if not owner_a or not owner_b then
		return;
	end
	if owner_a:inherits_from(Fixture) and owner_b:inherits_from(Fixture) then
		table.push(self.contact_callbacks, { func = owner_a.end_contact, args = { owner_a, owner_b, contact } });
		table.push(self.contact_callbacks, { func = owner_b.end_contact, args = { owner_b, owner_a, contact } });
	end
end

local draw_physics_debug = false;
crystal.cmd.add("showPhysicsOverlay", function() draw_physics_debug = true; end);
crystal.cmd.add("hidePhysicsOverlay", function() draw_physics_debug = false; end);

PhysicsSystem.draw_debug = function(self)
	if draw_physics_debug then
		for body in pairs(self.with_body:components(crystal.Body)) do
			local body = body:inner();
			local x, y = body:getX(), body:getY();
			x = math.round(x);
			y = math.round(y);
			for _, fixture in ipairs(body:getFixtures()) do
				local color = self:fixture_color(fixture);
				self:draw_shape(x, y, fixture:getShape(), color);
			end
		end
	end
end


local palette;
---@private
---@param fixture love.Fixture
---@return { [1]: number, [2]: number, [3]: number }
PhysicsSystem.fixture_color = function(self, fixture)
	assert(fixture);
	if not palette then
		palette = {
			crystal.Color.sunflower,
			crystal.Color.energos,
			crystal.Color.blue_martina,
			crystal.Color.lavender_rose,
			crystal.Color.bara_red,
			crystal.Color.puffins_bill,
			crystal.Color.pixelated_grass,
			crystal.Color.merchant_marine_blue,
			crystal.Color.forgotten_purple,
			crystal.Color.hollyhock,
			crystal.Color.red_pigment,
			crystal.Color.turkish_aqua,
			crystal.Color.leagues_under_the_sea,
			crystal.Color.circumorbital_ring,
			crystal.Color.magenta_purple,
			crystal.Color.mediterranean_sea,
		};
	end
	local categories, _, _ = fixture:getFilterData();
	for i = 0, 15 do
		if bit.band(categories, bit.lshift(1, i)) > 0 then
			return palette[i + 1];
		end
	end
	return palette[1];
end

---@private
---@param x number
---@param y number
---@param shape love.Shape
---@param color { [1]: number, [2]: number, [3]: number }
PhysicsSystem.draw_shape = function(self, x, y, shape, color)
	love.graphics.push("all");
	love.graphics.translate(x, y);
	love.graphics.setLineJoin("bevel");
	love.graphics.setLineStyle("smooth");

	love.graphics.setColor(color:alpha(.6));
	if shape:getType() == "polygon" then
		love.graphics.polygon("fill", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("fill", x, y, shape:getRadius(), 16);
	end

	love.graphics.setColor(color);
	if shape:getType() == "polygon" then
		love.graphics.setLineWidth(1);
		love.graphics.polygon("line", shape:getPoints());
	elseif shape:getType() == "circle" then
		love.graphics.setLineWidth(1);
		local x, y = shape:getPoint();
		love.graphics.circle("line", x, y, shape:getRadius(), 16);
	elseif shape:getType() == "chain" then
		love.graphics.setLineWidth(2);
		love.graphics.setPointSize(6 * crystal.window.viewport_scale());
		if shape:getVertexCount() >= 3 then
			local points = { shape:getPoints() };
			table.pop(points);
			table.pop(points);
			love.graphics.polygon("line", points);
			love.graphics.points(points);
		end
	end

	love.graphics.pop();
end

--#region Tests

crystal.test.add("Movement component moves things", function()
	local ecs = crystal.ECS:new();
	local physics_system = ecs:add_system(crystal.PhysicsSystem);

	local entity = ecs:spawn(crystal.Entity);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.Movement);

	entity:set_heading(0);
	entity:set_speed(100);
	x, y = entity:position();
	assert(x == 0 and y == 0);

	ecs:update();
	for i = 1, 100 do
		physics_system:simulate_physics(0.01);
	end
	local x, y = entity:position();
	assert(math.abs(x - 100) < 0.01);
	assert(math.abs(y) < 0.01);
end);

crystal.test.add("Can attach entity to another", function()
	local ecs = crystal.ECS:new();
	local physics_system = ecs:add_system(crystal.PhysicsSystem);

	local parent = ecs:spawn(crystal.Entity);
	parent:add_component(crystal.Body);
	parent:set_position(9, 2);

	local child = ecs:spawn(crystal.Entity);
	child:add_component(crystal.Body);
	child:attach_to(parent);
	local x, y = child:position();
	assert(x == 9);
	assert(y == 2);

	parent:set_position(100, 50);
	local x, y = child:position();
	assert(x == 100);
	assert(y == 50);

	parent:apply_impulse(20, 20);
	ecs:update();
	physics_system:simulate_physics(0.01);

	assert(child:distance_to_entity(parent) == 0);
end);

crystal.test.add("Can detach entities", function()
	local ecs = crystal.ECS:new();
	ecs:add_system(crystal.PhysicsSystem);

	local parent = ecs:spawn(crystal.Entity);
	parent:add_component(crystal.Body);
	parent:set_position(9, 2);

	local child = ecs:spawn(crystal.Entity);
	child:add_component(crystal.Body);
	child:attach_to(parent);
	local x, y = child:position();
	assert(x == 9);
	assert(y == 2);

	child:detach_from_parent();
	parent:set_position(100, 50);
	local x, y = child:position();
	assert(x == 9);
	assert(y == 2);
end);

crystal.test.add("Colliders block movement", function()
	local all_categories = {
		solid = 1,
	};

	local colliding = false;

	local ecs = crystal.ECS:new();
	local physics_system = ecs:add_system(crystal.PhysicsSystem);

	local entity = ecs:spawn(crystal.Entity);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.Movement);
	local collider = entity:add_component(crystal.Collider, love.physics.newRectangleShape(10, 10));
	collider.all_categories = all_categories;
	collider.on_collide = function() colliding = true; end;
	collider.on_uncollide = function() colliding = false; end;
	entity:set_heading(0);
	entity:set_speed(100);
	entity:set_categories("solid");
	entity:enable_collision_with("solid");

	local obstacle = ecs:spawn(crystal.Entity);
	obstacle:add_component(crystal.Body, "static");
	obstacle:set_position(50, 0);
	local collider = obstacle:add_component(crystal.Collider, love.physics.newRectangleShape(10, 10));
	collider.all_categories = all_categories;
	collider:set_categories("solid");
	collider:enable_collision_with("solid");

	ecs:update();
	for i = 1, 100 do
		physics_system:simulate_physics(0.01);
	end
	local x, y = entity:position();
	assert(colliding);
	assert(next(entity:collisions()));
	assert(math.abs(x - 40) < 1);
	assert(y == 0);

	entity:set_heading(math.pi);
	for i = 1, 100 do
		physics_system:simulate_physics(0.01);
	end
	local x, y = entity:position();
	assert(not colliding);
end);

crystal.test.add("Colliders activate sensors", function()
	local all_categories = {
		solid = 1,
		trigger = 1,
	};

	local activated = false;
	local deactivated = false;
	local found_activation = false;

	local ecs = crystal.ECS:new();
	local physics_system = ecs:add_system(crystal.PhysicsSystem);

	local entity = ecs:spawn(crystal.Entity);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.Movement);
	local collider = entity:add_component(crystal.Collider, love.physics.newRectangleShape(10, 10));
	collider.all_categories = all_categories;
	entity:set_heading(0);
	entity:set_speed(100);
	entity:set_categories("solid");
	entity:enable_collision_with("solid", "trigger");

	local trigger = ecs:spawn(crystal.Entity);
	trigger:add_component(crystal.Body, "static");
	trigger:set_position(50, 0);
	local sensor = trigger:add_component(crystal.Sensor, love.physics.newRectangleShape(10, 10));
	sensor.all_categories = all_categories;
	sensor:set_categories("trigger");
	sensor:enable_activation_by("solid");
	sensor.on_activate = function() activated = true; end;
	sensor.on_deactivate = function() deactivated = true; end

	ecs:update();
	for i = 1, 100 do
		physics_system:simulate_physics(0.01);
		if next(trigger:activations()) then
			found_activation = true;
		end
	end
	local x, y = entity:position();
	assert(math.abs(x - 100) < 1);
	assert(found_activation);
	assert(activated);
	assert(deactivated);
end);

crystal.test.add("Can draw physics overlay", function(context)
	local ecs = crystal.ECS:new();
	local physics_system = ecs:add_system(crystal.PhysicsSystem);

	local a = ecs:spawn(crystal.Entity);
	a:add_component(crystal.Body);
	a:add_component(crystal.Collider, love.physics.newRectangleShape(20, 20));
	a:set_position(100, 100);

	local b = ecs:spawn(crystal.Entity);
	b:add_component(crystal.Body);
	b:add_component(crystal.Collider, love.physics.newChainShape(true, 0, 0, 20, 0, 25, 10));
	b:set_position(150, 100);

	local b = ecs:spawn(crystal.Entity);
	b:add_component(crystal.Body);
	b:add_component(crystal.Collider, love.physics.newCircleShape(12));
	b:set_position(50, 100);

	ecs:update(0);
	crystal.cmd.run("showPhysicsOverlay");
	physics_system:draw_debug();
	crystal.cmd.run("hidePhysicsOverlay");

	-- Cannot do screenshot comparison as love shapes draw slightly differently based on graphics drivers
end);

--#endregion

return PhysicsSystem;
