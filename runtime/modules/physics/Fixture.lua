local bit = require("bit");
local TableUtils = require("utils/TableUtils");

---@class Fixture : Component
---@field protected fixture love.Fixture
---@field private enabled boolean # user-driven
---@field private active boolean # driven by lifecycle of the component
---@field private categories number
---@field private mask number
---@field private group number
---@field private contact_fixtures { [Fixture]: Entity }
local Fixture = Class("Fixture", crystal.Component);

Fixture.init = function(self, physics_body, shape)
	assert(physics_body:inherits_from("PhysicsBody"));
	assert(shape:typeOf("Shape"));
	self.enabled = true;
	self.active = false;
	self.categories = 0;
	self.mask = 0;
	self.group = 0;
	self.contact_fixtures = {};
	self.fixture = love.physics.newFixture(physics_body:body(), shape, 0);
	self.fixture:setUserData(self);
	self:update_filter_data();
end

---@private
Fixture.update_filter_data = function(self)
	local effective = self.active and self.enabled;
	self.fixture:setFilterData(self.categories, effective and self.mask or 0, self.group);
end

---@param ... string
Fixture.set_categories = function(self, ...)
	self.categories = 0;
	for i = 1, select("#", ...) do
		local category = crystal.physics.category(select(i, ...));
		self.categories = bit.bor(self.categories, category);
	end
	self:update_filter_data();
end

---@param ... string
Fixture.add_to_mask = function(self, ...)
	for i = 1, select("#", ...) do
		local category = crystal.physics.category(select(i, ...));
		self.mask = bit.bor(self.mask, category);
	end
	self:update_filter_data();
end

---@param ... string
Fixture.remove_from_mask = function(self, ...)
	for i = 1, select("#", ...) do
		local category = crystal.physics.category(select(i, ...));
		self.mask = bit.band(self.mask, bit.bnot(category));
	end
	self:update_filter_data();
end

---@return love.Shape
Fixture.shape = function(self)
	return self.fixture:getShape();
end

Fixture.on_added = function(self)
	self.active = true;
	self:update_filter_data();
end

Fixture.on_removed = function(self)
	self.fixture:destroy();
	self.fixture = nil;
end

Fixture.enable = function(self)
	self.enabled = true;
	self:update_filter_data();
end

Fixture.disable = function(self)
	self.enabled = false;
	self:update_filter_data();
end

---@return { [Fixture]: Entity }
Fixture.active_contacts = function(self)
	return TableUtils.shallowCopy(self.contact_fixtures);
end

Fixture.begin_contact = function(self, other_fixture, contact)
	self.contact_fixtures[other_fixture] = other_fixture:entity();
	self:on_begin_contact(other_fixture, other_fixture:entity(), contact);
end

Fixture.end_contact = function(self, other_fixture, contact)
	self.contact_fixtures[other_fixture] = nil;
	self:on_end_contact(other_fixture, other_fixture:entity(), contact);
end

Fixture.on_begin_contact = function(self, other_fixture, other_entity, contact)
end

Fixture.on_end_contact = function(self, other_fixture, other_entity, contact)
end

return Fixture;
