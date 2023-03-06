local Fixture = require("modules/physics/Fixture");
local Colors = require("resources/Colors");
local MathUtils = require("utils/MathUtils");

---@class PhysicsSystem : System
---@field private world love.World
---@field private with_body Query
---@field private with_movement Query
---@field private with_fixture Query
---@field private contact_callbacks { func: fun(), args: table }[]
local PhysicsSystem = Class("PhysicsSystem", crystal.System);

PhysicsSystem.init = function(self, world)
	assert(world);
	self.world = world;
	self.with_body = self:add_query({ "PhysicsBody" });
	self.with_movement = self:add_query({ "PhysicsBody", "Movement" });
	self.with_fixture = self:add_query({ "PhysicsBody", "Fixture" });

	self.contact_callbacks = {};
	self.world:setCallbacks(
		function(...) self:begin_contact(...) end,
		function(...) self:end_contact(...) end
	);
end

PhysicsSystem.before_physics = function(self, dt)
	for physics_body in pairs(self.with_body:added_components("PhysicsBody")) do
		physics_body:on_added();
	end

	for physics_body in pairs(self.with_body:removed_components("PhysicsBody")) do
		physics_body:on_removed();
	end

	for fixture in pairs(self.with_fixture:added_components("Fixture")) do
		fixture:on_added();
	end

	for fixture in pairs(self.with_fixture:removed_components("Fixture")) do
		fixture:on_removed();
	end

	for entity in pairs(self.with_movement:entities()) do
		local movement = entity:component("Movement");
		local physics_body = entity:component("PhysicsBody");
		if movement:is_enabled() then
			local speed = movement:speed();
			local angle = movement:heading();
			if angle then
				physics_body:set_angle(angle);
				local dx = math.cos(angle);
				local dy = math.sin(angle);
				physics_body:set_velocity(speed * dx, speed * dy);
			else
				physics_body:set_velocity(0, 0);
			end
		end
	end
end

PhysicsSystem.during_physics = function(self, dt)
	self.world:update(dt);
	for _, callback in ipairs(self.contact_callbacks) do
		callback.func(unpack(callback.args));
	end
	self.contact_callbacks = {};
end

PhysicsSystem.begin_contact = function(self, fixture_a, fixture_b, contact)
	local owner_a = fixture_a:getUserData();
	local owner_b = fixture_b:getUserData();
	if not owner_a or not owner_b then
		return;
	end
	if owner_a:inherits_from(Fixture) and owner_b:inherits_from(Fixture) then
		table.insert(self.contact_callbacks, { func = owner_a.begin_contact, args = { owner_a, owner_b, contact } });
		table.insert(self.contact_callbacks, { func = owner_b.begin_contact, args = { owner_b, owner_a, contact } });
	end
end

PhysicsSystem.end_contact = function(self, fixture_a, fixture_b, contact)
	local owner_a = fixture_a:getUserData();
	local owner_b = fixture_b:getUserData();
	if not owner_a or not owner_b then
		return;
	end
	if owner_a:inherits_from(Fixture) and owner_b:inherits_from(Fixture) then
		table.insert(self.contact_callbacks, { func = owner_a.end_contact, args = { owner_a, owner_b, contact } });
		table.insert(self.contact_callbacks, { func = owner_b.end_contact, args = { owner_b, owner_a, contact } });
	end
end

local draw_physics_debug = false;

PhysicsSystem.draw_debug = function(self)
	if draw_physics_debug then
		for physics_body in pairs(self.with_body:components(crystal.PhysicsBody)) do
			local body = physics_body:body();
			local x, y = body:getX(), body:getY();
			x = MathUtils.round(x);
			y = MathUtils.round(y);
			for _, fixture in ipairs(body:getFixtures()) do
				local color = self:fixture_color(fixture);
				self:draw_shape(x, y, fixture:getShape(), color);
			end
		end
	end
end

crystal.cmd.add("showPhysicsOverlay", function()
	draw_physics_debug = true;
end);

crystal.cmd.add("hidePhysicsOverlay", function()
	draw_physics_debug = false;
end);

local palette = {
	Colors.sunflower,
	Colors.energos,
	Colors.blue_martina,
	Colors.lavender_rose,
	Colors.bara_red,

	Colors.puffins_bill,
	Colors.pixelated_grass,
	Colors.merchant_marine_blue,
	Colors.forgotten_purple,
	Colors.hollyhock,

	Colors.red_pigment,
	Colors.turkish_aqua,
	Colors.leagues_under_the_sea,
	Colors.circumorbital_ring,
	Colors.magenta_purple,

	Colors.mediterranean_sea,
};

---@private
PhysicsSystem.fixture_color = function(self, fixture)
	assert(fixture);
	local categories, _, _ = fixture:getFilterData();
	for i = 0, 15 do
		if bit.band(categories, bit.lshift(1, i)) > 0 then
			return palette[i + 1];
		end
	end
	return palette[1];
end

---@private
PhysicsSystem.draw_shape = function(self, x, y, shape, color)
	love.graphics.push("all");
	love.graphics.translate(x, y);
	love.graphics.setLineJoin("miter");
	love.graphics.setLineStyle("rough");
	love.graphics.setLineWidth(1);

	love.graphics.setColor(color:alpha(.6));
	if shape:getType() == "polygon" then
		love.graphics.polygon("fill", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("fill", x, y, shape:getRadius(), 16);
	end

	love.graphics.setColor(color);
	if shape:getType() == "polygon" then
		love.graphics.polygon("line", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("line", x, y, shape:getRadius(), 16);
	end

	love.graphics.pop();
end

-- TODO re-write tests

return PhysicsSystem;
