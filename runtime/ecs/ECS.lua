local TableUtils = require("utils/TableUtils");
local Component = require("ecs/Component");
local Event = require("ecs/Event");
local System = require("ecs/System");
local Query = require("ecs/query/Query");

local ECS = Class("ECS");

local registerComponent = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:is_instance_of(Component));

	local class = component:class();

	if not self._entityToComponent[entity] then
		self._entityToComponent[entity] = {};
	end
	assert(not self._entityToComponent[entity][class]);
	self._entityToComponent[entity][class] = component;

	if not self._entityToComponents[entity] then
		self._entityToComponents[entity] = {};
	end

	local baseClass = class;
	while baseClass ~= Component do
		assert(self._entityToComponents[entity]);
		if not self._entityToComponents[entity][baseClass] then
			self._entityToComponents[entity][baseClass] = {};
		end
		assert(not self._entityToComponents[entity][baseClass][component]);
		self._entityToComponents[entity][baseClass][component] = true;

		if not self._componentClassToEntities[baseClass] then
			self._componentClassToEntities[baseClass] = {};
		end
		if not self._componentClassToEntities[baseClass][entity] then
			self._componentClassToEntities[baseClass][entity] = {};
		end
		assert(not self._componentClassToEntities[baseClass][entity][component]);
		self._componentClassToEntities[baseClass][entity][component] = true;

		baseClass = baseClass.super;
	end
end

local unregisterComponent = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:is_instance_of(Component));

	local class = component:class();
	assert(class);

	assert(self._entityToComponent[entity][class]);
	self._entityToComponent[entity][class] = nil;

	local baseClass = class;
	while baseClass ~= Component do
		assert(self._entityToComponents[entity][baseClass][component]);
		self._entityToComponents[entity][baseClass][component] = nil;
		if TableUtils.countKeys(self._entityToComponents[entity][baseClass]) == 0 then
			self._entityToComponents[entity][baseClass] = nil;
		end

		assert(self._componentClassToEntities[baseClass][entity][component]);
		self._componentClassToEntities[baseClass][entity][component] = nil;
		if TableUtils.countKeys(self._componentClassToEntities[baseClass][entity]) == 0 then
			self._componentClassToEntities[baseClass][entity] = nil;
		end

		baseClass = baseClass.super;
	end
end

local registerEntity = function(self, entity)
	assert(not self._entities[entity]);
	self._entities[entity] = true;
end

local unregisterEntity = function(self, entity)
	if self._entityToComponent[entity] then
		local components = TableUtils.shallowCopy(self._entityToComponent[entity]);
		for _, component in pairs(components) do
			unregisterComponent(self, entity, component);
		end
	end
	assert(self._entities[entity]);
	self._entities[entity] = nil;
	self._entityToComponent[entity] = nil;
	self._entityToComponents[entity] = nil;
end

ECS.init = function(self)
	self._entities = {};
	self._entityToComponent = {};
	self._entityToComponents = {};
	self._componentClassToEntities = {};

	self._queries = {};
	self._componentClassToQueries = {};

	self._systems = {};
	self._events = {};

	self._entityNursery = {};
	self._entityGraveyard = {};
	self._componentNursery = {};
	self._componentGraveyard = {};
end

ECS.update = function(self)
	for query in pairs(self._queries) do
		query:flush();
	end

	-- Remove components

	for entity, components in pairs(self._componentGraveyard) do
		for class, component in pairs(components) do
			unregisterComponent(self, entity, component);
			if not self._entityGraveyard[entity] then
				local baseClass = class;
				while baseClass ~= Component do
					if self._componentClassToQueries[baseClass] then
						for query in pairs(self._componentClassToQueries[baseClass]) do
							query:onComponentRemoved(entity, component);
						end
					end
					baseClass = baseClass.super;
				end
			end
		end
	end

	-- Remove entities

	for entity in pairs(self._entityGraveyard) do
		for query in pairs(self._queries) do
			query:onEntityRemoved(entity);
		end
		unregisterEntity(self, entity);
	end

	-- Add components

	for entity, components in pairs(self._componentNursery) do
		for class, component in pairs(components) do
			registerComponent(self, entity, component);
			if not self._entityNursery[entity] then
				local baseClass = class;
				while baseClass ~= Component do
					if self._componentClassToQueries[baseClass] then
						for query in pairs(self._componentClassToQueries[baseClass]) do
							query:onComponentAdded(entity, component);
						end
					end
					baseClass = baseClass.super;
				end
			end
		end
	end

	-- Add entities

	for entity in pairs(self._entityNursery) do
		registerEntity(self, entity);
		for query in pairs(self._queries) do
			query:onEntityAdded(entity);
		end
	end

	self._events = {};
	self._entityGraveyard = {};
	self._componentGraveyard = {};
	self._entityNursery = {};
	self._componentNursery = {};
end

ECS.notifySystems = function(self, notification, ...)
	for _, system in ipairs(self._systems) do
		if system[notification] then
			system[notification](system, ...);
		end
	end
end

ECS.spawn = function(self, class, ...)
	assert(class);
	local entity = {};
	self._entityNursery[entity] = {};
	class:placement_new(entity, self, ...);
	return entity;
end

ECS.despawn = function(self, entity)
	assert(entity);
	if self._entityNursery[entity] then
		self._entityNursery[entity] = nil;
	else
		assert(self._entities[entity]);
		self._entityGraveyard[entity] = true;
	end
	self._componentNursery[entity] = nil;
	self._componentGraveyard[entity] = nil;
end

ECS.addComponent = function(self, entity, component)
	assert(component);
	assert(component:is_instance_of(Component));
	assert(not component:getEntity());
	assert(entity:isValid());
	component:setEntity(entity);
	local graveyard = self._componentGraveyard[entity];
	if graveyard and graveyard[component:class()] then
		graveyard[component:class()] = nil;
	else
		assert(not entity:getExactComponent(component:class()));
		local nursery = self._componentNursery[entity];
		if not nursery then
			nursery = {};
			self._componentNursery[entity] = nursery;
		end
		nursery[component:class()] = component;
	end
end

ECS.removeComponent = function(self, entity, component)
	assert(component);
	assert(component:is_instance_of(Component));
	assert(component:getEntity() == entity);
	assert(entity:isValid());
	component:setEntity(nil);
	local nursery = self._componentNursery[entity];
	if nursery and nursery[component:class()] then
		nursery[component:class()] = nil;
	else
		assert(entity:getExactComponent(component:class()) == component);
		local graveyard = self._componentGraveyard[entity];
		if not graveyard then
			graveyard = {};
			self._componentGraveyard[entity] = graveyard;
		end
		graveyard[component:class()] = component;
	end
end

ECS.addQuery = function(self, query)
	assert(TableUtils.countKeys(self._entities) == 0);
	assert(not self._queries[query]);
	assert(query:is_instance_of(Query));
	self._queries[query] = true;
	for _, class in pairs(query:getClasses()) do
		if not self._componentClassToQueries[class] then
			self._componentClassToQueries[class] = {};
		end
		self._componentClassToQueries[class][query] = true;
	end
end

ECS.addSystem = function(self, system)
	assert(system);
	assert(system:is_instance_of(System));
	table.insert(self._systems, system);
end

ECS.addEvent = function(self, event)
	assert(event);
	assert(event:is_instance_of(Event));
	assert(event:getEntity():isValid());
	local baseClass = event:class();
	while baseClass do
		local events = self._events[baseClass];
		if not events then
			events = {};
			self._events[baseClass] = events;
		end
		table.insert(events, event);
		baseClass = baseClass.super;
	end
end

ECS.getSystem = function(self, class)
	for _, system in ipairs(self._systems) do
		if system:is_instance_of(class) then
			return system;
		end
	end
	return nil;
end

ECS.getAllEntities = function(self)
	return TableUtils.shallowCopy(self._entities);
end

ECS.getAllEntitiesWith = function(self, class)
	assert(class);
	local source = self._componentClassToEntities[class] or {};
	local output = {};
	for entity in pairs(source) do
		output[entity] = true;
	end
	return output;
end

ECS.getExactComponent = function(self, entity, class)
	assert(entity);
	assert(class);

	if self._componentNursery[entity] then
		if self._componentNursery[entity][class] then
			return self._componentNursery[entity][class];
		end
	end

	if self._componentGraveyard[entity] then
		if self._componentGraveyard[entity][class] then
			return nil;
		end
	end

	if self._entityToComponent[entity] then
		local exactMatch = self._entityToComponent[entity][class];
		if exactMatch then
			return exactMatch;
		end
	end
end

ECS.getComponent = function(self, entity, class)
	assert(entity);
	assert(class);
	local matches = self:getComponents(entity, class);
	for match in pairs(matches) do
		return match;
	end
end

ECS.getComponents = function(self, entity, baseClass)
	local candidates = {};
	if self._entityToComponents[entity] then
		if self._entityToComponents[entity][baseClass] then
			candidates = TableUtils.shallowCopy(self._entityToComponents[entity][baseClass]);
		end
	end
	if self._componentNursery[entity] then
		for _, component in pairs(self._componentNursery[entity]) do
			if component:is_instance_of(baseClass) then
				candidates[component] = true;
			end
		end
	end

	local output = {};
	local graveyard = self._componentGraveyard[entity] or {};
	for component in pairs(candidates) do
		if graveyard[component:class()] ~= component then
			output[component] = true;
		end
	end
	return output;
end

ECS.getAllComponents = function(self, class)
	assert(class);
	local source = self._componentClassToEntities[class] or {};
	local output = {};
	for _, components in pairs(source) do
		for component in pairs(components) do
			table.insert(output, component);
		end
	end
	return output;
end

ECS.getEvents = function(self, class)
	if not self._events[class] then
		return {};
	end
	return TableUtils.shallowCopy(self._events[class]);
end

--#region

local Entity = require("ecs/Entity");
local EitherComponent = require("ecs/query/EitherComponent");
local AllComponents = require("ecs/query/AllComponents");

crystal.test.add("Spawn and despawn entity", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	assert(not ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);
	ecs:update(0);
	assert(ecs:getAllEntities()[a]);

	ecs:despawn(b);
	assert(ecs:getAllEntities()[b]);
	ecs:update(0);
	assert(ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);

	ecs:despawn(a);
	assert(ecs:getAllEntities()[a]);
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);
end);

crystal.test.add("Spawn and despawn entity between updates", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	assert(not ecs:getAllEntities()[a]);
	ecs:despawn(a);
	assert(not ecs:getAllEntities()[a]);
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
end);

crystal.test.add("Add and remove component", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local snoot = Snoot:new();
	a:addComponent(snoot);
	assert(snoot:getEntity() == a);
	ecs:update();
	assert(snoot:getEntity() == a);

	a:removeComponent(snoot);
	assert(snoot:getEntity() == nil);
	ecs:update();
	assert(snoot:getEntity() == nil);
end);

crystal.test.add("Add and remove component between updates", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);

	local a = ecs:spawn(Entity);
	local snoot = Snoot:new();
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == snoot);
	a:removeComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	ecs:update();
	assert(a:getComponent(Snoot) == nil);

	local a = ecs:spawn(Entity);
	local snoot = Snoot:new();

	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == snoot);
	a:removeComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == snoot);
	ecs:update();
	assert(a:getComponent(Snoot) == snoot);
end);

crystal.test.add("Cannot add component to despawned entity", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	ecs:update(0);
	a:addComponent(Component:new());
	a:despawn();
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
	assert(not a:getExactComponent(Component));
end);

crystal.test.add("Transfer component", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local snoot = Snoot:new();

	a:addComponent(snoot);
	ecs:update();

	local success, errorMessage = pcall(function()
			b:addComponent(snoot);
		end);
	assert(not success);
	assert(#errorMessage > 1);

	a:removeComponent(snoot);
	assert(snoot:getEntity() == nil);
	assert(a:getComponent(Snoot) == nil);
	ecs:update();
	assert(snoot:getEntity() == nil);
	assert(a:getComponent(Snoot) == nil);

	b:addComponent(snoot);
	assert(snoot:getEntity() == b);
	assert(b:getComponent(Snoot) == snoot);
	ecs:update();
	assert(snoot:getEntity() == b);
	assert(b:getComponent(Snoot) == snoot);
end);

crystal.test.add("Prevent duplicate components", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	a:addComponent(Snoot:new());

	local success = pcall(function()
			a:addComponent(Snoot:new());
		end);
	assert(not success);

	ecs:update();

	local success = pcall(function()
			a:addComponent(Snoot:new());
		end);
	assert(not success);
end);

crystal.test.add("Get exact component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local Bonk = Class:test("Bonk", Snoot);
	local boop = Boop:new();
	local bonk = Bonk:new();

	a:addComponent(boop);
	assert(a:getExactComponent(Boop) == boop);
	assert(a:getExactComponent(Bonk) == nil);
	assert(a:getExactComponent(Snoot) == nil);
	ecs:update();
	assert(a:getExactComponent(Boop) == boop);
	assert(a:getExactComponent(Bonk) == nil);
	assert(a:getExactComponent(Snoot) == nil);

	a:addComponent(bonk);
	assert(a:getExactComponent(Boop) == boop);
	assert(a:getExactComponent(Bonk) == bonk);
	assert(a:getExactComponent(Snoot) == nil);
	ecs:update();
	assert(a:getExactComponent(Boop) == boop);
	assert(a:getExactComponent(Bonk) == bonk);
	assert(a:getExactComponent(Snoot) == nil);

	a:removeComponent(boop);
	assert(a:getExactComponent(Boop) == nil);
	assert(a:getExactComponent(Bonk) == bonk);
	assert(a:getExactComponent(Snoot) == nil);
	ecs:update();
	assert(a:getExactComponent(Boop) == nil);
	assert(a:getExactComponent(Bonk) == bonk);
	assert(a:getExactComponent(Snoot) == nil);
end);

crystal.test.add("Get component", function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local Bonk = Class:test("Bonk", Snoot);
	local boop = Boop:new();
	local bonk = Bonk:new();

	a:addComponent(boop);
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Bonk) == nil);
	assert(a:getComponent(Snoot) == boop);
	ecs:update();
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Bonk) == nil);
	assert(a:getComponent(Snoot) == boop);

	a:addComponent(bonk);
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Bonk) == bonk);
	assert(a:getComponent(Snoot) ~= nil);
	ecs:update();
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Bonk) == bonk);
	assert(a:getComponent(Snoot) ~= nil);

	a:removeComponent(boop);
	assert(a:getComponent(Boop) == nil);
	assert(a:getComponent(Bonk) == bonk);
	assert(a:getComponent(Snoot) == bonk);
	ecs:update();
	assert(a:getComponent(Boop) == nil);
	assert(a:getComponent(Bonk) == bonk);
	assert(a:getComponent(Snoot) == bonk);
end);

crystal.test.add("Get components", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	assert(TableUtils.equals({ [boop] = true }, a:getComponents(Snoot)));
	ecs:update();
	assert(TableUtils.equals({ [boop] = true }, a:getComponents(Snoot)));
	a:removeComponent(boop);
	assert(TableUtils.equals({}, a:getComponents(Snoot)));
	ecs:update();
	assert(TableUtils.equals({}, a:getComponents(Snoot)));
end);

crystal.test.add("Get all entities with component", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(TableUtils.equals({ [a] = true }, ecs:getAllEntitiesWith(Snoot)));
	a:removeComponent(boop);
	ecs:update();
	assert(TableUtils.equals({}, ecs:getAllEntitiesWith(Snoot)));
end);

crystal.test.add("Get all components", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local snoot = Snoot:new();
	local boop = Boop:new();
	a:addComponent(boop);
	a:addComponent(snoot);
	ecs:update();
	assert(#ecs:getAllComponents(Snoot) == 2);
	assert(#ecs:getAllComponents(Boop) == 1);
	a:removeComponent(boop);
	ecs:update();
	assert(#ecs:getAllComponents(Snoot) == 1);
	assert(#ecs:getAllComponents(Boop) == 0);
	a:removeComponent(snoot);
	ecs:update();
	assert(#ecs:getAllComponents(Snoot) == 0);
	assert(#ecs:getAllComponents(Boop) == 0);
end);

crystal.test.add("Despawned entities don't leave components behind", function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Comp = Class:test("Comp", Component);
	local comp = Comp:new();
	a:addComponent(comp);
	ecs:update();
	assert(#ecs:getAllComponents(Comp) == 1);
	a:despawn();
	ecs:update();
	assert(#ecs:getAllComponents(Comp) == 0);
end);

crystal.test.add("Get system", function()
	local ecs = ECS:new();

	local SystemA = Class:test("SystemA", System);
	local SystemB = Class:test("SystemB", System);

	local systemA = SystemA:new(ecs);
	ecs:addSystem(systemA);
	assert(ecs:getSystem(SystemA) == systemA);
	assert(ecs:getSystem(SystemB) == nil);

	local systemB = SystemB:new(ecs);
	ecs:addSystem(systemB);
	assert(ecs:getSystem(SystemA) == systemA);
	assert(ecs:getSystem(SystemB) == systemB);
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
		ecs:addSystem(system);
	end
	assert(sentinel == 0);
	ecs:notifySystems("randomEvent");
	assert(sentinel == 0);
	ecs:notifySystems("update");
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
	ecs:addSystem(system);
	ecs:notifySystems("update", true);
	assert(ran);
end);

crystal.test.add("Query maintains list of entities", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local query = AllComponents:new({ Snoot });
	ecs:addQuery(query);

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	local snoot = Snoot:new();
	b:addComponent(snoot);
	assert(not query:getEntities()[a]);
	assert(not query:getEntities()[b]);
	assert(not query:contains(a));
	assert(not query:contains(b));

	ecs:update();
	assert(not query:getEntities()[a]);
	assert(query:getEntities()[b]);
	assert(not query:contains(a));
	assert(query:contains(b));

	b:removeComponent(snoot);
	assert(not query:getEntities()[a]);
	assert(query:getEntities()[b]);
	assert(not query:contains(a));
	assert(query:contains(b));

	ecs:update();
	assert(not query:getEntities()[a]);
	assert(not query:getEntities()[b]);
	assert(not query:contains(a));
	assert(not query:contains(b));
end);

crystal.test.add("Query entity list captures derived components", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local Boop = Class:test("Boop", Snoot);
	local query = AllComponents:new({ Snoot });
	ecs:addQuery(query);

	local a = ecs:spawn(Entity);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(query:getEntities()[a]);

	a:removeComponent(boop);
	ecs:update();
	assert(not query:getEntities()[a]);
end);

crystal.test.add("Query maintains changelog of entities", function()
	local ecs = ECS:new();
	local Snoot = Class:test("Snoot", Component);
	local query = AllComponents:new({ Snoot });
	ecs:addQuery(query);

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	local snoot = Snoot:new();
	b:addComponent(snoot);
	assert(not query:getAddedEntities()[b]);

	ecs:update();
	assert(not query:getAddedEntities()[a]);
	assert(query:getAddedEntities()[b]);
	ecs:update();
	assert(not query:getAddedEntities()[b]);

	b:removeComponent(snoot);
	assert(not query:getRemovedEntities()[b]);

	ecs:update();
	assert(query:getRemovedEntities()[b]);

	ecs:update();
	assert(not query:getRemovedEntities()[b]);
end);

crystal.test.add("Query maintains changelog of components", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local query = AllComponents:new({ BaseComp });
	ecs:addQuery(query);

	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local CompC = Class:test("CompC", BaseComp);
	local compA = CompA:new();
	local compB = CompB:new();
	local compC = CompC:new();

	local a = ecs:spawn(Entity);
	a:addComponent(compA);
	a:addComponent(compB);
	assert(TableUtils.equals({}, query:getAddedComponents(BaseComp)));

	ecs:update();
	assert(TableUtils.equals({ [compA] = a,[compB] = a }, query:getAddedComponents(BaseComp)));

	a:addComponent(compC);
	ecs:update();
	assert(TableUtils.equals({ [compC] = a }, query:getAddedComponents(BaseComp)));

	a:removeComponent(compA);
	ecs:update();
	assert(TableUtils.equals({ [compA] = a }, query:getRemovedComponents(BaseComp)));
end);

crystal.test.add("Changelog of components is updated when entity despawns", function()
	local ecs = ECS:new();
	local Comp = Class:test("Comp", Component);
	local query = AllComponents:new({ Comp });
	ecs:addQuery(query);

	local comp = Comp:new();

	local a = ecs:spawn(Entity);
	a:addComponent(comp);
	ecs:update();
	assert(query:getAddedComponents(Comp)[comp] == a);

	a:despawn();
	ecs:update();
	assert(query:getRemovedComponents(Comp)[comp] == a);
end);

crystal.test.add("Query component changelog works when component is added and removed between updates", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local query = EitherComponent:new({ CompA, CompB });
	ecs:addQuery(query);

	local compA = CompA:new();
	local compB = CompB:new();

	local a = ecs:spawn(Entity);
	a:addComponent(compA);
	ecs:update();

	a:addComponent(compB);
	a:removeComponent(compB);
	ecs:update();
	assert(TableUtils.equals({}, query:getAddedComponents(CompB)));

	a:removeComponent(compA);
	a:addComponent(compA);
	ecs:update();
	assert(TableUtils.equals({}, query:getAddedComponents(CompA)));
end);

crystal.test.add("Query component changelog works for intersection query", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local CompC = Class:test("CompC", BaseComp);
	local query = AllComponents:new({ CompA, CompB, CompC });
	ecs:addQuery(query);

	local compA = CompA:new();
	local compB = CompB:new();
	local compC = CompC:new();

	local a = ecs:spawn(Entity);
	a:addComponent(compA);
	a:addComponent(compB);
	ecs:update();
	assert(not query:getAddedComponents(CompA)[compA]);
	assert(not query:getAddedComponents(CompB)[compB]);

	a:addComponent(compC);
	ecs:update();
	assert(query:getAddedComponents(CompA)[compA]);
	assert(query:getAddedComponents(CompB)[compB]);
	assert(query:getAddedComponents(CompC)[compC]);

	a:removeComponent(compA);
	ecs:update();
	assert(query:getRemovedComponents(CompA)[compA]);
	assert(query:getRemovedComponents(CompB)[compB]);
	assert(query:getRemovedComponents(CompC)[compC]);
end);

crystal.test.add("Query component changelog works for union query", function()
	local ecs = ECS:new();
	local BaseComp = Class:test("BaseComp", Component);
	local CompA = Class:test("CompA", BaseComp);
	local CompB = Class:test("CompB", BaseComp);
	local CompC = Class:test("CompC", BaseComp);
	local query = EitherComponent:new({ CompA, CompB, CompC });
	ecs:addQuery(query);

	local compA = CompA:new();
	local compB = CompB:new();
	local compC = CompC:new();

	local a = ecs:spawn(Entity);
	a:addComponent(compA);
	a:addComponent(compB);
	ecs:update();
	assert(query:getAddedComponents(CompA)[compA]);
	assert(query:getAddedComponents(CompB)[compB]);

	a:addComponent(compC);
	ecs:update();
	assert(not query:getAddedComponents(CompA)[compA]);
	assert(not query:getAddedComponents(CompB)[compB]);
	assert(query:getAddedComponents(CompC)[compC]);

	a:removeComponent(compA);
	ecs:update();
	assert(query:getRemovedComponents(CompA)[compA]);
	assert(not query:getRemovedComponents(CompB)[compB]);
	assert(not query:getRemovedComponents(CompC)[compC]);
end);

crystal.test.add("Events can be retrieved within the rest of the frame", function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	ecs:update();
	assert(#ecs:getEvents(Event) == 0);
	entity:createEvent(Event);
	assert(#ecs:getEvents(Event) == 1);
	entity:createEvent(Event);
	assert(#ecs:getEvents(Event) == 2);
	ecs:update();
	assert(#ecs:getEvents(Event) == 0);
end);

crystal.test.add("Events can be retrieved by base class", function()
	local MyEvent = Class:test("MyEvent", Event);
	local MyOtherEvent = Class:test("MyOtherEvent", Event);

	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);

	ecs:update();

	entity:createEvent(MyEvent);
	assert(#ecs:getEvents(Event) == 1);
	assert(#ecs:getEvents(MyEvent) == 1);
	assert(#ecs:getEvents(MyOtherEvent) == 0);

	entity:createEvent(MyOtherEvent);
	assert(#ecs:getEvents(Event) == 2);
	assert(#ecs:getEvents(MyEvent) == 1);
	assert(#ecs:getEvents(MyOtherEvent) == 1);
end);

--#endregion

return ECS;
