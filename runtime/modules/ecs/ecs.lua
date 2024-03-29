local Component = require(CRYSTAL_RUNTIME .. "modules/ecs/component");
local Entity = require(CRYSTAL_RUNTIME .. "modules/ecs/entity");
local Event = require(CRYSTAL_RUNTIME .. "modules/ecs/event");
local System = require(CRYSTAL_RUNTIME .. "modules/ecs/system");
local Query = require(CRYSTAL_RUNTIME .. "modules/ecs/query");

---@class ECS
---@field private _entities { [Entity]: boolean }
---@field private _components { [Entity]: { [Component]: boolean } }
---@field private entity_to_components { [Entity]: { [Class]: { [Component]: boolean } } }
---@field private components_by_class { [Class]: { [Entity]: { [Component]: boolean } } }
---@field private queries { [Query]: boolean }
---@field private queries_by_class { [Class]: { [Query]: boolean } }
---@field private systems System[]
---@field private contexts { [string]: fun(): any }
---@field private _events { [Class]: Event[] }
---@field private entity_nursery { [Entity]: boolean }
---@field private entity_graveyard { [Entity]: boolean }
---@field private component_nursery { [Entity]: { [Class]: { [Component]: boolean } } }
---@field private component_graveyard { [Entity]: { [Class]: { [Component]: boolean } } }
local ECS = Class("ECS");

ECS.init = function(self)
	self._entities = {};
	self._components = {};
	self.entity_to_components = {};
	self.components_by_class = {};

	self.queries = {};
	self.queries_by_class = {};

	self.systems = {};
	self.contexts = {};
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

	for entity, components_by_class in pairs(self.component_graveyard) do
		for class, components in pairs(components_by_class) do
			for component, _ in pairs(components) do
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
	end

	-- Remove entities

	for entity in pairs(self.entity_graveyard) do
		for query in pairs(self.queries) do
			query:on_entity_despawned(entity);
		end
		self:unregister_entity(entity);
	end

	-- Add components

	for entity, components_by_class in pairs(self.component_nursery) do
		for class, components in pairs(components_by_class) do
			for component, _ in pairs(components) do
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
		class = Class:by_name(class);
	end
	assert(class);
	local entity = { _ecs = self, _is_valid = true };
	self.entity_nursery[entity] = true;
	class:placement_new(entity, ...);
	assert(entity:ecs() == self);
	return entity;
end

---@param entity Entity
ECS.despawn = function(self, entity)
	assert(entity);
	assert(entity:is_valid());
	entity:invalidate();
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
	assert(component:inherits_from(Component));
	assert(component:entity() == entity);
	assert(entity:is_valid());
	local graveyard = self.component_graveyard[entity];
	if graveyard and graveyard[component:class()] and graveyard[component:class()][component] then
		graveyard[component:class()][component] = nil;
	else
		if not self.component_nursery[entity] then
			self.component_nursery[entity] = {};
		end
		if not self.component_nursery[entity][component:class()] then
			self.component_nursery[entity][component:class()] = {};
		end
		self.component_nursery[entity][component:class()][component] = true;
	end
end

---@param entity Entity
---@param component Component
ECS.remove_component = function(self, entity, component)
	assert(component);
	assert(component:inherits_from(Component));
	assert(component:entity() == entity);
	assert(entity:is_valid());
	assert(component:is_valid());
	component:invalidate();
	local nursery = self.component_nursery[entity];
	if nursery and nursery[component:class()] and nursery[component:class()][component] then
		nursery[component:class()][component] = nil;
	else
		if not self.component_graveyard[entity] then
			self.component_graveyard[entity] = {};
		end
		if not self.component_graveyard[entity][component:class()] then
			self.component_graveyard[entity][component:class()] = {};
		end
		self.component_graveyard[entity][component:class()][component] = true;
	end
end

---@param classes string[]
ECS.add_query = function(self, classes)
	assert(table.is_empty(self._entities));
	local query = Query:new(classes);
	self.queries[query] = true;
	for _, class in ipairs(query:classes()) do
		if not self.queries_by_class[class] then
			self.queries_by_class[class] = {};
		end
		self.queries_by_class[class][query] = true;
	end
	return query;
end

---@generic T
---@param class `T`
---@return T
ECS.add_system = function(self, class, ...)
	if type(class) == "string" then
		class = Class:by_name(class);
	end
	assert(class);
	local system = { _ecs = self };
	class:placement_new(system, ...);
	assert(system:inherits_from(System));
	assert(system:ecs() == self);
	table.push(self.systems, system);
	return system;
end

---@generic T
---@param class T
---@return T
ECS.system = function(self, class)
	if type(class) == "string" then
		class = Class:by_name(class);
	end
	for _, system in ipairs(self.systems) do
		if system:inherits_from(class) then
			return system;
		end
	end
	return nil;
end

---@param name string
---@param value any
ECS.add_context = function(self, name, value)
	assert(type(name) == "string");
	self.contexts[name] = value;
end

---@param name string
---@return any
ECS.context = function(self, name)
	return self.contexts[name];
end

---@param event Event
ECS.add_event = function(self, event)
	assert(event);
	assert(event:inherits_from(Event));
	assert(event:entity():is_valid());
	local base_class = event:class();
	while base_class do
		local events = self._events[base_class];
		if not events then
			events = {};
			self._events[base_class] = events;
		end
		table.push(events, event);
		base_class = base_class.super;
	end
end

---@return { [Entity]: boolean }
ECS.entities = function(self)
	return table.copy(self._entities);
end

---@class string
---@return { [Entity]: boolean }
ECS.entities_with = function(self, class)
	if type(class) == "string" then
		class = Class:by_name(class);
	end
	assert(class);
	local output = {};

	if self.components_by_class[class] then
		for entity, components in pairs(self.components_by_class[class]) do
			if not self.entity_graveyard[entity] then
				for component in pairs(components) do
					if not (self.component_graveyard[entity]
							and self.component_graveyard[entity][component:class()]
							and self.component_graveyard[entity][component:class()][component])
					then
						output[entity] = true;
						break;
					end
				end
			end
		end
	end

	for entity, component_by_class in pairs(self.component_nursery) do
		for class_iter, components in pairs(component_by_class) do
			if class_iter:inherits_from(class) and next(components) then
				output[entity] = true;
				break;
			end
		end
	end

	return output;
end

---@generic T
---@param entity Entity
---@param class `T`
---@return T
ECS.component_on_entity = function(self, entity, class)
	if type(class) == "string" then
		class = Class:by_name(class);
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
		base_class = Class:by_name(base_class);
	end

	local output = {};

	if self.entity_to_components[entity] then
		if self.entity_to_components[entity][base_class] then
			output = table.copy(self.entity_to_components[entity][base_class]);
		end
	end

	if self.component_nursery[entity] then
		for class, components in pairs(self.component_nursery[entity]) do
			for component, _ in pairs(components) do
				if component:inherits_from(base_class) then
					output[component] = true;
				end
			end
		end
	end

	local output_copy = table.copy(output);
	if self.component_graveyard[entity] then
		for component in pairs(output_copy) do
			if self.component_graveyard[entity][component:class()] then
				if self.component_graveyard[entity][component:class()][component] then
					output[component] = nil;
				end
			end
		end
	end

	return output;
end

---@generic T
---@param class `T`
---@return { [T]: boolean }
ECS.components = function(self, class)
	if type(class) == "string" then
		class = Class:by_name(class);
	end
	assert(class);
	local output = {};

	if self.components_by_class[class] then
		for entity, components in pairs(self.components_by_class[class]) do
			if not self.entity_graveyard[entity] then
				for component in pairs(components) do
					output[component] = true;
				end
			end
		end
	end

	for _, components_by_class in pairs(self.component_nursery) do
		for class_iter, components in pairs(components_by_class) do
			if class_iter:inherits_from(class) then
				for component in pairs(components) do
					output[component] = true;
				end
			end
		end
	end

	for _, components_by_class in pairs(self.component_graveyard) do
		for class_iter, components in pairs(components_by_class) do
			if class_iter:inherits_from(class) then
				for component in pairs(components) do
					output[component] = nil;
				end
			end
		end
	end

	return output;
end

---@generic T
---@param class `T`
---@return T[]
ECS.events = function(self, class)
	if type(class) == "string" then
		class = Class:by_name(class);
	end
	assert(class);
	if not self._events[class] then
		return {};
	end
	return table.copy(self._events[class]);
end

---@private
---@param entity Entity
---@param component Component
ECS.register_component = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:inherits_from(Component));

	local class = component:class();

	if not self._components[entity] then
		self._components[entity] = {};
	end
	self._components[entity][component] = true;

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
	assert(component:inherits_from(Component));

	local class = component:class();
	assert(class);

	assert(self._components[entity][component]);
	self._components[entity][component] = nil;

	local base_class = class;
	while base_class ~= Component do
		assert(self.entity_to_components[entity][base_class][component]);
		self.entity_to_components[entity][base_class][component] = nil;
		if table.is_empty(self.entity_to_components[entity][base_class]) then
			self.entity_to_components[entity][base_class] = nil;
		end

		assert(self.components_by_class[base_class][entity][component]);
		self.components_by_class[base_class][entity][component] = nil;
		if table.is_empty(self.components_by_class[base_class][entity]) then
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
	if self._components[entity] then
		local components_to_unregister = table.copy(self._components[entity]);
		for component in pairs(components_to_unregister) do
			self:unregister_component(entity, component);
		end
	end
	assert(self._entities[entity]);
	self._entities[entity] = nil;
	self._components[entity] = nil;
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
	assert(not snoot:is_valid());
	assert(snoot:entity());
	ecs:update();
	assert(not snoot:is_valid());
	assert(snoot:entity());
end);

crystal.test.add("Add and remove components of same class", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);

	local a = ecs:spawn(Entity);
	local snoot1 = a:add_component(Snoot);
	local snoot2 = a:add_component(Snoot);
	a:remove_component(snoot2);
	ecs:update();
	assert(a:components(Snoot)[snoot1]);
	assert(not a:components(Snoot)[snoot2]);
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
	assert(not a:component(Component));
end);

crystal.test.add("Can get component by base class", function()
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

crystal.test.add("Can get components by base class", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);

	local boop1 = a:add_component(Boop);
	assert(table.equals(a:components(Snoot), { [boop1] = true }));

	local boop2 = a:add_component(Boop);
	assert(table.equals(a:components(Snoot), { [boop1] = true, [boop2] = true }));

	ecs:update();
	assert(table.equals(a:components(Snoot), { [boop1] = true, [boop2] = true }));

	a:remove_component(boop1);
	assert(table.equals(a:components(Snoot), { [boop2] = true }));

	a:remove_component(boop2);
	assert(table.is_empty(a:components(Snoot)));

	ecs:update();
	assert(table.is_empty(a:components(Snoot)));
end);

crystal.test.add("Get all entities with component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);

	-- After add component
	local boop = a:add_component(Boop);
	assert(table.equals(ecs:entities_with(Snoot), { [a] = true }));
	ecs:update();
	assert(table.equals(ecs:entities_with(Snoot), { [a] = true }));

	-- After remove component
	a:remove_component(boop);
	assert(table.is_empty(ecs:entities_with(Snoot)));
	ecs:update();
	assert(table.is_empty(ecs:entities_with(Snoot)));

	-- After add/remove component with no update
	local boop = a:add_component(Boop);
	a:remove_component(boop);
	assert(table.is_empty(ecs:entities_with(Snoot)));

	-- After despawn
	a:add_component(Boop);
	ecs:update();
	assert(table.equals(ecs:entities_with(Snoot), { [a] = true }));
	a:despawn();
	assert(table.is_empty(ecs:entities_with(Snoot)));

	-- After despawn with no update
	local a = ecs:spawn(Entity);
	a:add_component(Boop);
	assert(table.equals(ecs:entities_with(Snoot), { [a] = true }));
	a:despawn();
	assert(table.is_empty(ecs:entities_with(Snoot)));
end);

crystal.test.add("Can get components by class", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);

	local boop = a:add_component(Boop);
	local snoot = a:add_component(Snoot);
	assert(table.count(ecs:components(Snoot)) == 2);
	assert(table.count(ecs:components(Boop)) == 1);
	ecs:update();
	assert(table.count(ecs:components(Snoot)) == 2);
	assert(table.count(ecs:components(Boop)) == 1);

	a:remove_component(boop);
	assert(table.count(ecs:components(Snoot)) == 1);
	assert(table.is_empty(ecs:components(Boop)));
	ecs:update();
	assert(table.count(ecs:components(Snoot)) == 1);
	assert(table.is_empty(ecs:components(Boop)));

	a:remove_component(snoot);
	assert(table.is_empty(ecs:components(Snoot)));
	assert(table.is_empty(ecs:components(Boop)));
	ecs:update();
	assert(table.is_empty(ecs:components(Snoot)));
	assert(table.is_empty(ecs:components(Boop)));
end);

crystal.test.add("Despawned entities don't leave components behind", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Comp = Class:test("Comp", Component);
	local comp = a:add_component(Comp);
	assert(table.count(ecs:components(Comp)) == 1);
	ecs:update();
	assert(table.count(ecs:components(Comp)) == 1);

	a:despawn();
	assert(table.is_empty(ecs:components(Comp)));
	ecs:update();
	assert(table.is_empty(ecs:components(Comp)));
end);

crystal.test.add("Get system", function()
	local ecs = ECS:new();

	local SystemA = Class:test("SystemA", System);
	local SystemB = Class:test("SystemB", System);

	local systemA = ecs:add_system(SystemA);
	assert(ecs:system(SystemA) == systemA);
	assert(ecs:system(SystemB) == nil);

	local systemB = ecs:add_system(SystemB);
	assert(ecs:system(SystemA) == systemA);
	assert(ecs:system(SystemB) == systemB);
end);

crystal.test.add("Systems run when notified", function()
	local ecs = ECS:new();

	local sentinel = 0;
	local MySystem = Class:test("MySystem", System);
	MySystem.update = function(self)
		assert(sentinel == self.value - 1);
		sentinel = self.value;
	end

	for i = 1, 10 do
		local system = ecs:add_system(MySystem);
		system.value = i;
	end
	assert(sentinel == 0);
	ecs:notify_systems("random_event");
	assert(sentinel == 0);
	ecs:notify_systems("update");
	assert(sentinel == 10);
end);

crystal.test.add("Systems receive parameters", function()
	local ecs = ECS:new();

	local ran = false;
	local MySystem = Class:test("MySystem", System);
	MySystem.update = function(self, value)
		assert(value);
		ran = true;
	end
	ecs:add_system(MySystem);
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

crystal.test.add("Query entity list includes derived components", function()
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


crystal.test.add("Query maintains list of components", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local query = ecs:add_query({ Snoot });

	local a = ecs:spawn(Entity);

	-- Add component
	local snoot = a:add_component(Snoot);
	assert(table.is_empty(query:components()));
	ecs:update();
	assert(table.equals(query:components(), { [snoot] = true }));

	-- Bonus component
	local bonus_snoot = a:add_component(Snoot);
	assert(table.equals(query:components(), { [snoot] = true }));
	ecs:update();
	assert(table.equals(query:components(), { [snoot] = true, [bonus_snoot] = true }));
	a:remove_component(bonus_snoot);
	ecs:update();
	assert(table.equals(query:components(), { [snoot] = true }));

	-- Remove component
	a:remove_component(snoot);
	assert(table.equals(query:components(), { [snoot] = true }));
	ecs:update();
	assert(table.is_empty(query:components()));

	-- Add/remove component without update
	local snoot = a:add_component(Snoot);
	a:remove_component(snoot);
	ecs:update();
	assert(table.is_empty(query:components()));

	-- Despawn
	a:add_component(Snoot);
	ecs:update();
	a:despawn();
	ecs:update();
	assert(table.is_empty(query:components()));

	-- Despawn with no intermediate update
	local a = ecs:spawn(Entity);
	a:add_component(Snoot);
	a:despawn();
	ecs:update();
	assert(table.is_empty(query:components()));
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
	assert(table.is_empty(query:added_components(BaseComp)));

	ecs:update();
	assert(table.equals(query:added_components(BaseComp), { [compA] = a, [compB] = a }));

	local compC = a:add_component(CompC);
	ecs:update();
	assert(table.equals(query:added_components(BaseComp), { [compC] = a }));

	a:remove_component(compA);
	ecs:update();
	assert(table.equals(query:removed_components(BaseComp), { [compA] = a }));
end);

crystal.test.add("Query changelog of components is updated when entity despawns", function()
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

crystal.test.add("Query changelog of components works for queries involving multiple components", function()
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

crystal.test.add("Can swap components", function()
	local MyComp = Class:test("MyComp", Component);

	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	local query = ecs:add_query({ MyComp });

	ecs:update();
	local a = entity:add_component(MyComp);
	ecs:update();
	assert(table.equals(query:added_components(MyComp), { [a] = entity }));

	entity:remove_component(a);
	local b = entity:add_component(MyComp);
	ecs:update();
	assert(table.equals(query:removed_components(MyComp), { [a] = entity }));
	assert(table.equals(query:added_components(MyComp), { [b] = entity }));

	local c = entity:add_component(MyComp);
	entity:remove_component(b);
	ecs:update();
	assert(table.equals(query:removed_components(MyComp), { [b] = entity }));
	assert(table.equals(query:added_components(MyComp), { [c] = entity }));

	ecs:update();
end);


crystal.test.add("Can add and retrieve context value", function()
	local value = {};
	local ecs = ECS:new();
	ecs:add_context("v", value);
	assert(ecs:context("v") == value);
	assert(ecs:context("x") == nil);

	local entity = ecs:spawn(Entity);
	assert(entity:context("v") == value);
	assert(entity:context("x") == nil);
end);

--#endregion

return ECS;
