local TableUtils = require("utils/TableUtils");
local Component = require("ecs/Component");
local Event = require("ecs/Event");
local System = require("ecs/System");
local Query = require("ecs/query/Query");

local ECS = Class("ECS");

local registerComponent = function(self, entity, component)
	assert(entity);
	assert(component);
	assert(component:isInstanceOf(Component));

	local class = component:getClass();

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
	assert(component:isInstanceOf(Component));

	local class = component:getClass();
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
	class:placementNew(entity, self, ...);
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
	assert(component:isInstanceOf(Component));
	assert(not component:getEntity());
	assert(entity:isValid());
	component:setEntity(entity);
	local graveyard = self._componentGraveyard[entity];
	if graveyard and graveyard[component:getClass()] then
		graveyard[component:getClass()] = nil;
	else
		assert(not entity:getExactComponent(component:getClass()));
		local nursery = self._componentNursery[entity];
		if not nursery then
			nursery = {};
			self._componentNursery[entity] = nursery;
		end
		nursery[component:getClass()] = component;
	end
end

ECS.removeComponent = function(self, entity, component)
	assert(component);
	assert(component:isInstanceOf(Component));
	assert(component:getEntity() == entity);
	assert(entity:isValid());
	component:setEntity(nil);
	local nursery = self._componentNursery[entity];
	if nursery and nursery[component:getClass()] then
		nursery[component:getClass()] = nil;
	else
		assert(entity:getExactComponent(component:getClass()) == component);
		local graveyard = self._componentGraveyard[entity];
		if not graveyard then
			graveyard = {};
			self._componentGraveyard[entity] = graveyard;
		end
		graveyard[component:getClass()] = component;
	end
end

ECS.addQuery = function(self, query)
	assert(TableUtils.countKeys(self._entities) == 0);
	assert(not self._queries[query]);
	assert(query:isInstanceOf(Query));
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
	assert(system:isInstanceOf(System));
	table.insert(self._systems, system);
end

ECS.addEvent = function(self, event)
	assert(event);
	assert(event:isInstanceOf(Event));
	assert(event:getEntity():isValid());
	local baseClass = event:getClass();
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
		if system:isInstanceOf(class) then
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
			if component:isInstanceOf(baseClass) then
				candidates[component] = true;
			end
		end
	end

	local output = {};
	local graveyard = self._componentGraveyard[entity] or {};
	for component in pairs(candidates) do
		if graveyard[component:getClass()] ~= component then
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

return ECS;
