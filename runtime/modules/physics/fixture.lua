local bit = require("bit");

---@class Fixture : Component
---@field protected fixture love.Fixture
---@field private all_categories { [string]: number}
---@field private enabled boolean # user-driven
---@field private active boolean # driven by lifecycle of the component
---@field private categories number
---@field private mask number
---@field private group number
---@field private contact_fixtures { [Fixture]: Entity }
local Fixture = Class("Fixture", crystal.Component);

Fixture.all_categories = {};

Fixture.init = function(self, shape)
	local body = self:entity():component(crystal.Body);
	assert(body:inherits_from("Body"));
	assert(shape:typeOf("Shape"));
	self.enabled = true;
	self.active = false;
	self.categories = 0;
	self.mask = 0;
	self.group = 0;
	self.contact_fixtures = {};
	self.fixture = love.physics.newFixture(body:inner(), shape, 0);
	self.fixture:setUserData(self);
	self:update_filter_data();
end

---@private
Fixture.update_filter_data = function(self)
	local effective = self.active and self.enabled;
	self.fixture:setFilterData(self.categories, effective and self.mask or 0, self.group);
end

---@private
---@param name string
---@returns number
Fixture.category = function(self, name)
	assert(type(name) == "string");
	assert(self.all_categories[name]);
	return self.all_categories[name];
end

---@param ... string
Fixture.set_categories = function(self, ...)
	self.categories = 0;
	for i = 1, select("#", ...) do
		local category = self:category(select(i, ...));
		self.categories = bit.bor(self.categories, category);
	end
	self:update_filter_data();
end

---@param ... string
Fixture.add_category_to_mask = function(self, ...)
	for i = 1, select("#", ...) do
		local category = self:category(select(i, ...));
		self.mask = bit.bor(self.mask, category);
	end
	self:update_filter_data();
end

---@param ... string
Fixture.remove_category_from_mask = function(self, ...)
	for i = 1, select("#", ...) do
		local category = self:category(select(i, ...));
		self.mask = bit.band(self.mask, bit.bnot(category));
	end
	self:update_filter_data();
end

Fixture.add_all_categories_to_mask = function(self)
	self.mask = 65535;
	self:update_filter_data();
end

Fixture.remove_all_categories_from_mask = function(self)
	self.mask = 0;
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
	if not self.fixture:isDestroyed() then
		self.fixture:destroy();
	end
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
	return table.copy(self.contact_fixtures);
end

Fixture.begin_contact = function(self, other_fixture, contact)
	if not self.enabled or not other_fixture.enabled then
		return;
	end
	local this_entity = self:entity();
	local other_entity = other_fixture:entity();
	if this_entity and this_entity:is_valid() and other_entity and other_entity:is_valid() then
		self.contact_fixtures[other_fixture] = other_entity;
		self:on_begin_contact(other_fixture, other_entity, contact);
	end
end

Fixture.end_contact = function(self, other_fixture, contact)
	local this_entity = self:entity();
	if this_entity and this_entity:is_valid() then
		if self.contact_fixtures[other_fixture] then
			self.contact_fixtures[other_fixture] = nil;
			self:on_end_contact(other_fixture, other_fixture:entity(), contact);
		end
	end
end

return Fixture;
