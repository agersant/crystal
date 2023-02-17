local TableUtils = require("utils/TableUtils");
local Component = require("modules/ecs/Component");
local Entity = require("modules/ecs/Entity");
local Event = require("modules/ecs/Event");
local System = require("modules/ecs/System");
local Query = require("modules/ecs/Query");

---@class ECS
---@field private _entities { [Entity]: boolean }
---@field private entity_to_component { [Entity]: { [Class]: Component } }
---@field private entity_to_components { [Entity]: { [Class]: { [Component]: boolean } } }
---@field private components_by_class { [Class]: { [Entity]: { [Component]: boolean } } }
---@field private queries { [Query]: boolean }
---@field private queries_by_class { [Class]: { [Query]: boolean } }
---@field private systems System[]
---@field private _events { [Class]: Event[] }
---@field private entity_nursery { [Entity]: boolean }
---@field private entity_nursery { [Entity]: boolean }
---@field private component_nursery { [Entity]: { [Class]: Component } }
---@field private component_graveyard { [Entity]: { [Class]: Component } }
local ECS = Class("ECS");

ECS.init = function(self)
	self._entities = {};
	self.entity_to_component = {};
	self.entity_to_components = {};
	self.components_by_class = {};

	self.queries = {};
	self.queries_by_class = {};

	self.systems = {};
	self._events = {};

	self.entity_nursery = {};
	self.entity_graveyard = {};
	self.component_nursery = {};
	self.component_graveyard = {};
end

ECS.update = function(self)
	for query in pairs(self.queries) do
		query:flush();
	end

	-- Remove components

	for entity, components in pairs(self.component_graveyard) do
		for class, component in pairs(components) do
			self:unregister_component(entity, component);
			if not self.entity_graveyard[entity] then
				local base_class = class;
				while base_class ~= Component do
					if self.queries_by_class[base_class] then
						for query in pairs(self.queries_by_class[base_class]) do
							query:on_component_removed(entity, component);
						end
					end
					base_class = base_class.super;
				end
			end
		end
	end

	-- Remove entities

	for entity in pairs(self.entity_graveyard) do
		for query in pairs(self.queries) do
			query:on_entity_despawned(entity);
		end
		self:unregister_entity(entity);
	end

	-- Add components

	for entity, components in pairs(self.component_nursery) do
		for class, component in pairs(components) do
			self:register_component(entity, component);
			if not self.entity_nursery[entity] then
				local base_class = class;
				while base_class ~= Component do
					if self.queries_by_class[base_class] then
						for query in pairs(self.queries_by_class[base_class]) do
							query:on_component_added(entity, component);
						end
					end
					base_class = base_class.super;
				end
			end
		end
	end

	-- Add entities

	for entity in pairs(self.entity_nursery) do
		self:register_entity(entity);
		for query in pairs(self.queries) do
			query:on_entity_spawned(entity);
		end
	end

	self._events = {};
	self.entity_graveyard = {};
	self.component_graveyard = {};
	self.entity_nursery = {};
	self.component_nursery = {};
end

---@param notification string
ECS.notify_systems = function(self, notification, ...)
	for _, system in ipairs(self.systems) do
		if system[notification] then
			system[notification](system, ...);
		end
	end
end

---@generic T
---@param class `T`
---@return T
ECS.spawn = function(self, class, ...)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	local entity = {};
	self.entity_nursery[entity] = true;
	class:placement_new(entity, self, ...);
	return entity;
end

---@param entity Entity
ECS.despawn = function(self, entity)
	assert(entity);
	if self.entity_nursery[entity] then
		self.entity_nursery[entity] = nil;
	else
		assert(self._entities[entity]);
		self.entity_graveyard[entity] = true;
	end
	self.component_nursery[entity] = nil;
	self.component_graveyard[entity] = nil;
end

---@param entity Entity
---@param component Component
ECS.add_component = function(self, entity, component)
	assert(component);
	assert(component:is_instance_of(Component));
	assert(component:entity() == entity);
	assert(entity:is_valid());
	local graveyard = self.component_graveyard[entity];
	if graveyard and graveyard[component:class()] then
		graveyard[component:class()] = nil;
	else
		assert(not entity:exact_component(component:class()));
		local nursery = self.component_nursery[entity];
		if not nursery then
			nursery = {};
			self.component_nursery[entity] = nursery;
		end
		nursery[component:class()] = component;
	end
end

---@param entity Entity
---@param component Component
ECS.remove_component = function(self, entity, component)
	assert(component);
	assert(component:is_instance_of(Component));
	assert(component:entity() == entity);
	assert(entity:is_valid());
	component:remove_from_entity();
	local nursery = self.component_nursery[entity];
	if nursery and nursery[component:class()] then
		nursery[component:class()] = nil;
	else
		assert(entity:exact_component(component:class()) == component);
		local graveyard = self.component_graveyard[entity];
		if not graveyard then
			graveyard = {};
			self.component_graveyard[entity] = graveyard;
		end
		graveyard[component:class()] = component;
	end
end

---@param classes string[]
ECS.add_query = function(self, classes)
	assert(TableUtils.countKeys(self._entities) == 0);
	local query = Query:new(classes);
	self.queries[query] = true;
	for _, class in pairs(query:classes()) do
		if not self.queries_by_class[class] then
			self.queries_by_class[class] = {};
		end
		self.queries_by_class[class][query] = true;
	end
	return query;
end

---@param System
ECS.add_system = function(self, system)
	assert(system);
	assert(system:is_instance_of(System));
	table.insert(self.systems, system);
end

---@param event Event
ECS.addEvent = function(self, event)
	assert(event);
	assert(event:is_instance_of(Event));
	assert(event:entity():is_valid());
	local base_class = event:class();
	while base_class do
		local events = self._events[base_class];
		if not events then
			events = {};
			self._events[base_class] = events;
		end
		table.insert(events, event);
		base_class = base_class.super;
	end
end

---@generic T
---@param class T
---@return T
ECS.system = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	for _, system in ipairs(self.systems) do
		if system:is_instance_of(class) then
			return system;
		end
	end
	return nil;
end

---@return { [Entity]: boolean }
ECS.entities = function(self)
	return TableUtils.shallowCopy(self._entities);
end

---@class string
---@return { [Entity]: boolean }
ECS.entities_with = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	local source = self.components_by_class[class] or {};
	local output = {};
	for entity in pairs(source) do
		output[entity] = true;
	end
	return output;
end

---@generic T
---@param entity Entity
---@param class `T`
---@return T
ECS.component_exact_on_entity = function(self, entity, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(entity);
	assert(class);

	if self.component_nursery[entity] then
		if self.component_nursery[entity][class] then
			return self.component_nursery[entity][class];
		end
	end

	if self.component_graveyard[entity] then
		if self.component_graveyard[entity][class] then
			return nil;
		end
	end

	if self.entity_to_component[entity] then
		local exactMatch = self.entity_to_component[entity][class];
		if exactMatch then
			return exactMatch;
		end
	end
end

---@generic T
---@param entity Entity
---@param class `T`
---@return T
ECS.component_on_entity = function(self, entity, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(entity);
	assert(class);
	local matches = self:components_on_entity(entity, class);
	for match in pairs(matches) do
		return match;
	end
end

---@generic T
---@param entity Entity
---@param base_class `T`
---@return { [Component]: boolean }
ECS.components_on_entity = function(self, entity, base_class)
	if type(base_class) == "string" then
		base_class = Class:get_by_name(base_class);
	end

	local candidates = {};
	if self.entity_to_components[entity] then
		if self.entity_to_components[entity][base_class] then
			candidates = TableUtils.shallowCopy(self.entity_to_components[entity][base_class]);
		end
	end
	if self.component_nursery[entity] then
		for _, component in pairs(self.component_nursery[entity]) do
			if component:is_instance_of(base_class) then
				candidates[component] = true;
			end
		end
	end

	local output = {};
	local graveyard = self.component_graveyard[entity] or {};
	for component in pairs(candidates) do
		if graveyard[component:class()] ~= component then
			output[component] = true;
		end
	end
	return output;
end

---@generic T
---@param class `T`
---@return T[]
ECS.components = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	local source = self.components_by_class[class] or {};
	local output = {};
	for _, components in pairs(source) do
		for component in pairs(components) do
			table.insert(output, component);
		end
	end
	return output;
end

---@generic T
---@param class `T`
---@return T[]
ECS.events = function(self, class)
	if type(class) == "string" then
		class = Class:get_by_name(class);
	end
	assert(class);
	if not self._events[class] then
		return {};
	end
	return TableUtils.shallowCopy(self._events[class]);
end

---@private
---@param entity Entity
---@param component Component
ECS.register_component = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:is_instance_of(Component));

	local class = component:class();

	if not self.entity_to_component[entity] then
		self.entity_to_component[entity] = {};
	end
	assert(not self.entity_to_component[entity][class]);
	self.entity_to_component[entity][class] = component;

	if not self.entity_to_components[entity] then
		self.entity_to_components[entity] = {};
	end

	local base_class = class;
	while base_class ~= Component do
		assert(self.entity_to_components[entity]);
		if not self.entity_to_components[entity][base_class] then
			self.entity_to_components[entity][base_class] = {};
		end
		assert(not self.entity_to_components[entity][base_class][component]);
		self.entity_to_components[entity][base_class][component] = true;

		if not self.components_by_class[base_class] then
			self.components_by_class[base_class] = {};
		end
		if not self.components_by_class[base_class][entity] then
			self.components_by_class[base_class][entity] = {};
		end
		assert(not self.components_by_class[base_class][entity][component]);
		self.components_by_class[base_class][entity][component] = true;

		base_class = base_class.super;
	end
end

---@private
---@param entity Entity
---@param component Component
ECS.unregister_component = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:is_instance_of(Component));

	local class = component:class();
	assert(class);

	assert(self.entity_to_component[entity][class]);
	self.entity_to_component[entity][class] = nil;

	local base_class = class;
	while base_class ~= Component do
		assert(self.entity_to_components[entity][base_class][component]);
		self.entity_to_components[entity][base_class][component] = nil;
		if TableUtils.countKeys(self.entity_to_components[entity][base_class]) == 0 then
			self.entity_to_components[entity][base_class] = nil;
		end

		assert(self.components_by_class[base_class][entity][component]);
		self.components_by_class[base_class][entity][component] = nil;
		if TableUtils.countKeys(self.components_by_class[base_class][entity]) == 0 then
			self.components_by_class[base_class][entity] = nil;
		end

		base_class = base_class.super;
	end
end

---@private
---@param entity Entity
ECS.register_entity = function(self, entity)
	assert(not self._entities[entity]);
	self._entities[entity] = true;
end

---@private
---@param entity Entity
ECS.unregister_entity = function(self, entity)
	if self.entity_to_component[entity] then
		local components = TableUtils.shallowCopy(self.entity_to_component[entity]);
		for _, component in pairs(components) do
			self:unregister_component(entity, component);
		end
	end
	assert(self._entities[entity]);
	self._entities[entity] = nil;
	self.entity_to_component[entity] = nil;
	self.entity_to_components[entity] = nil;
end

--#region

crystal.test.add("Spawn and despawn entity", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	assert(not ecs:entities()[a]);
	assert(not ecs:entities()[b]);
	ecs:update(0);
	assert(ecs:entities()[a]);

	ecs:despawn(b);
	assert(ecs:entities()[b]);
	ecs:update(0);
	assert(ecs:entities()[a]);
	assert(not ecs:entities()[b]);

	ecs:despawn(a);
	assert(ecs:entities()[a]);
	ecs:update(0);
	assert(not ecs:entities()[a]);
	assert(not ecs:entities()[b]);
end);

crystal.test.add("Spawn and despawn entity between updates", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	assert(not ecs:entities()[a]);
	ecs:despawn(a);
	assert(not ecs:entities()[a]);
	ecs:update(0);
	assert(not ecs:entities()[a]);
end);

crystal.test.add("Add and remove component", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local snoot = a:add_component(Snoot);
	assert(snoot:entity() == a);
	ecs:update();
	assert(snoot:entity() == a);

	a:remove_component(snoot);
	assert(snoot:entity() == nil);
	ecs:update();
	assert(snoot:entity() == nil);
end);

crystal.test.add("Add and remove component between updates", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);

	local a = ecs:spawn(Entity);
	local snoot = a:add_component(Snoot);
	assert(a:component(Snoot) == snoot);
	a:remove_component(snoot);
	assert(a:component(Snoot) == nil);
	ecs:update();
	assert(a:component(Snoot) == nil);

	local a = ecs:spawn(Entity);
	local snoot = a:add_component(Snoot);
	assert(a:component(Snoot) == snoot);
	a:remove_component(snoot);
	assert(a:component(Snoot) == nil);
	local snoot = a:add_component(snoot);
	assert(a:component(Snoot) == snoot);
	ecs:update();
	assert(a:component(Snoot) == snoot);
end);

crystal.test.add("Cannot add component to despawned entity", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	ecs:update(0);
	a:add_component(Component);
	a:despawn();
	ecs:update(0);
	assert(not ecs:entities()[a]);
	assert(not a:exact_component(Component));
end);

crystal.test.add("Prevent duplicate components", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	a:add_component(Snoot);

	local success = pcall(function()
		a:add_component(Snoot);
	end);
	assert(not success);

	ecs:update();

	local success = pcall(function()
		a:add_component(Snoot);
	end);
	assert(not success);
end);

crystal.test.add("Get exact component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local Bonk = Class:test("Bonk", Snoot);

	local boop = a:add_component(Boop);
	assert(a:exact_component(Boop) == boop);
	assert(a:exact_component(Bonk) == nil);
	assert(a:exact_component(Snoot) == nil);
	ecs:update();
	assert(a:exact_component(Boop) == boop);
	assert(a:exact_component(Bonk) == nil);
	assert(a:exact_component(Snoot) == nil);

	local bonk = a:add_component(Bonk);
	assert(a:exact_component(Boop) == boop);
	assert(a:exact_component(Bonk) == bonk);
	assert(a:exact_component(Snoot) == nil);
	ecs:update();
	assert(a:exact_component(Boop) == boop);
	assert(a:exact_component(Bonk) == bonk);
	assert(a:exact_component(Snoot) == nil);

	a:remove_component(boop);
	assert(a:exact_component(Boop) == nil);
	assert(a:exact_component(Bonk) == bonk);
	assert(a:exact_component(Snoot) == nil);
	ecs:update();
	assert(a:exact_component(Boop) == nil);
	assert(a:exact_component(Bonk) == bonk);
	assert(a:exact_component(Snoot) == nil);
end);

crystal.test.add("Get component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local Bonk = Class:test("Bonk", Snoot);

	local boop = a:add_component(Boop);
	assert(a:component(Boop) == boop);
	assert(a:component(Bonk) == nil);
	assert(a:component(Snoot) == boop);
	ecs:update();
	assert(a:component(Boop) == boop);
	assert(a:component(Bonk) == nil);
	assert(a:component(Snoot) == boop);

	local bonk = a:add_component(Bonk);
	assert(a:component(Boop) == boop);
	assert(a:component(Bonk) == bonk);
	assert(a:component(Snoot) ~= nil);
	ecs:update();
	assert(a:component(Boop) == boop);
	assert(a:component(Bonk) == bonk);
	assert(a:component(Snoot) ~= nil);

	a:remove_component(boop);
	assert(a:component(Boop) == nil);
	assert(a:component(Bonk) == bonk);
	assert(a:component(Snoot) == bonk);
	ecs:update();
	assert(a:component(Boop) == nil);
	assert(a:component(Bonk) == bonk);
	assert(a:component(Snoot) == bonk);
end);

crystal.test.add("Get components", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);

	local boop = a:add_component(Boop);
	assert(TableUtils.equals({ [boop] = true }, a:components(Snoot)));

	ecs:update();
	assert(TableUtils.equals({ [boop] = true }, a:components(Snoot)));

	a:remove_component(boop);
	assert(TableUtils.equals({}, a:components(Snoot)));

	ecs:update();
	assert(TableUtils.equals({}, a:components(Snoot)));
end);

crystal.test.add("Get all entities with component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local boop = a:add_component(Boop);

	ecs:update();
	assert(TableUtils.equals({ [a] = true }, ecs:entities_with(Snoot)));

	a:remove_component(boop);
	ecs:update();
	assert(TableUtils.equals({}, ecs:entities_with(Snoot)));
end);

crystal.test.add("Get all components", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local boop = a:add_component(Boop);
	local snoot = a:add_component(Snoot);
	ecs:update();
	assert(#ecs:components(Snoot) == 2);
	assert(#ecs:components(Boop) == 1);
	a:remove_component(boop);
	ecs:update();
	assert(#ecs:components(Snoot) == 1);
	assert(#ecs:components(Boop) == 0);
	a:remove_component(snoot);
	ecs:update();
	assert(#ecs:components(Snoot) == 0);
	assert(#ecs:components(Boop) == 0);
end);

crystal.test.add("Despawned entities don't leave components behind", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Comp = Class:test("Comp", Component);
	local comp = a:add_component(Comp);
	ecs:update();
	assert(#ecs:components(Comp) == 1);
	a:despawn();
	ecs:update();
	assert(#ecs:components(Comp) == 0);
end);

crystal.test.add("Get system", function()
	local ecs = ECS:new();

	local SystemA = Class:test("SystemA", crystal.System);
	local SystemB = Class:test("SystemB", crystal.System);

	local systemA = SystemA:new(ecs);
	ecs:add_system(systemA);
	assert(ecs:system(SystemA) == systemA);
	assert(ecs:system(SystemB) == nil);

	local systemB = SystemB:new(ecs);
	ecs:add_system(systemB);
	assert(ecs:system(SystemA) == systemA);
	assert(ecs:system(SystemB) == systemB);
end);

crystal.test.add("Systems run when notified", function()
	local ecs = ECS:new();

	local sentinel = 0;
	for i = 1, 10 do
		local j = i;
		local system = System:new(ecs);
		system.update = function()
			assert(sentinel == j - 1);
			sentinel = j;
		end
		ecs:add_system(system);
	end
	assert(sentinel == 0);
	ecs:notify_systems("randomEvent");
	assert(sentinel == 0);
	ecs:notify_systems("update");
	assert(sentinel == 10);
end);

crystal.test.add("Systems receive parameters", function()
	local ecs = ECS:new();

	local ran = false;
	local system = System:new(ecs);
	system.update = function(self, value)
		assert(self == system);
		assert(value);
		ran = true;
	end
	ecs:add_system(system);
	ecs:notify_systems("update", true);
	assert(ran);
end);

crystal.test.add("Query maintains list of entities", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local query = ecs:add_query({ Snoot });

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	local snoot = b:add_component(Snoot);
	assert(not query:entities()[a]);
	assert(not query:entities()[b]);
	assert(not query:contains(a));
	assert(not query:contains(b));

	ecs:update();
	assert(not query:entities()[a]);
	assert(query:entities()[b]);
	assert(not query:contains(a));
	assert(query:contains(b));

	b:remove_component(snoot);
	assert(not query:entities()[a]);
	assert(query:entities()[b]);
	assert(not query:contains(a));
	assert(query:contains(b));

	ecs:update();
	assert(not query:entities()[a]);
	assert(not query:entities()[b]);
	assert(not query:contains(a));
	assert(not query:contains(b));
end);

crystal.test.add("Query entity list captures derived components", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local query = ecs:add_query({ Snoot });

	local a = ecs:spawn(Entity);
	local boop = a:add_component(Boop);
	ecs:update();
	assert(query:entities()[a]);

	a:remove_component(boop);
	ecs:update();
	assert(not query:entities()[a]);
end);

crystal.test.add("Query maintains changelog of entities", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local query = ecs:add_query({ Snoot });

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	local snoot = b:add_component(Snoot);
	assert(not query:added_entities()[b]);

	ecs:update();
	assert(not query:added_entities()[a]);
	assert(query:added_entities()[b]);
	ecs:update();
	assert(not query:added_entities()[b]);

	b:remove_component(snoot);
	assert(not query:removed_entities()[b]);

	ecs:update();
	assert(query:removed_entities()[b]);

	ecs:update();
	assert(not query:removed_entities()[b]);
end);

crystal.test.add("Query maintains changelog of components", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local query = ecs:add_query({ BaseComp });

	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local CompC = Class:test("CompC", BaseComp);

	local a = ecs:spawn(Entity);
	local compA = a:add_component(CompA);
	local compB = a:add_component(CompB);
	assert(TableUtils.equals({}, query:added_components(BaseComp)));

	ecs:update();
	assert(TableUtils.equals({ [compA] = a,[compB] = a }, query:added_components(BaseComp)));

	local compC = a:add_component(CompC);
	ecs:update();
	assert(TableUtils.equals({ [compC] = a }, query:added_components(BaseComp)));

	a:remove_component(compA);
	ecs:update();
	assert(TableUtils.equals({ [compA] = a }, query:removed_components(BaseComp)));
end);

crystal.test.add("Changelog of components is updated when entity despawns", function()
	local ecs = ECS:new();
	local Comp = Class:test("Comp", Component);
	local query = ecs:add_query({ Comp });

	local a = ecs:spawn(Entity);
	local comp = a:add_component(Comp);
	ecs:update();
	assert(query:added_components(Comp)[comp] == a);

	a:despawn();
	ecs:update();
	assert(query:removed_components(Comp)[comp] == a);
end);

crystal.test.add("Query component changelog works for intersection query", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local CompC = Class:test("CompC", BaseComp);
	local query = ecs:add_query({ CompA, CompB, CompC });

	local a = ecs:spawn(Entity);
	local compA = a:add_component(CompA);
	local compB = a:add_component(CompB);
	ecs:update();
	assert(not query:added_components(CompA)[compA]);
	assert(not query:added_components(CompB)[compB]);

	local compC = a:add_component(CompC);
	ecs:update();
	assert(query:added_components(CompA)[compA]);
	assert(query:added_components(CompB)[compB]);
	assert(query:added_components(CompC)[compC]);

	a:remove_component(compA);
	ecs:update();
	assert(query:removed_components(CompA)[compA]);
	assert(query:removed_components(CompB)[compB]);
	assert(query:removed_components(CompC)[compC]);
end);

crystal.test.add("Events can be retrieved within the rest of the frame", function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	ecs:update();
	assert(#ecs:events(Event) == 0);
	entity:create_event(Event);
	assert(#ecs:events(Event) == 1);
	entity:create_event(Event);
	assert(#ecs:events(Event) == 2);
	ecs:update();
	assert(#ecs:events(Event) == 0);
end);

crystal.test.add("Events can be retrieved by base class", function()
	local MyEvent = Class:test("MyEvent", Event);
	local MyOtherEvent = Class:test("MyOtherEvent", Event);

	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);

	ecs:update();

	entity:create_event(MyEvent);
	assert(#ecs:events(Event) == 1);
	assert(#ecs:events(MyEvent) == 1);
	assert(#ecs:events(MyOtherEvent) == 0);

	entity:create_event(MyOtherEvent);
	assert(#ecs:events(Event) == 2);
	assert(#ecs:events(MyEvent) == 1);
	assert(#ecs:events(MyOtherEvent) == 1);
end);

--#endregion

return ECS;
