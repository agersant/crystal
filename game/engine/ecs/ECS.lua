require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");
local Component = require("engine/ecs/Component");
local System = require("engine/ecs/System");
local Query = require("engine/ecs/query/Query");

local ECS = Class("ECS");

local registerComponent = function(self, entity, component)
	assert(entity);
	assert(entity:isValid());
	assert(component);
	assert(component:isInstanceOf(Component));

	local class = component:getClass();

	assert(not self._entityToComponent[entity][class]);
	self._entityToComponent[entity][class] = component;

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

	component:setEntity(entity);
	component:activate();
end

local unregisterComponent = function(self, entity, component)
	assert(entity);
	assert(entity:isValid());
	assert(component);
	assert(component:isInstanceOf(Component));

	component:deactivate();
	component:setEntity(nil);

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
	entity:setIsValid(true);
	assert(not self._entities[entity]);
	self._entities[entity] = true;
	self._entityToComponent[entity] = {};
	self._entityToComponents[entity] = {};
end

local unregisterEntity = function(self, entity)
	assert(self._entityToComponent[entity]);
	local components = TableUtils.shallowCopy(self._entityToComponent[entity]);
	for _, component in pairs(components) do
		unregisterComponent(self, entity, component);
	end
	assert(self._entities[entity]);
	self._entities[entity] = nil;
	self._entityToComponent[entity] = nil;
	self._entityToComponents[entity] = nil;
	entity:setIsValid(false);
end

local updateQueries = function(self, entityNursery, entityGraveyard, componentNursery, componentGraveyard)
	for query in pairs(self._queries) do
		query:flush();
	end

	for entity in pairs(entityGraveyard) do
		for query in pairs(self._queries) do
			query:onEntityRemoved(entity);
		end
	end

	for entity in pairs(entityNursery) do
		for query in pairs(self._queries) do
			query:onEntityAdded(entity);
		end
	end

	for entity, components in pairs(componentGraveyard) do
		if not entityGraveyard[entity] then
			for class, component in pairs(components) do
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

	for entity, components in pairs(componentNursery) do
		if not entityNursery[entity] then
			for class, component in pairs(components) do
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
end

ECS.init = function(self)
	self._entities = {};
	self._entityToComponent = {};
	self._entityToComponents = {};
	self._componentClassToEntities = {};

	self._queries = {};
	self._componentClassToQueries = {};

	self._systems = {};

	self._entityNursery = {};
	self._entityGraveyard = {};
	self._componentNursery = {};
	self._componentGraveyard = {};
end

ECS.update = function(self)
	local entityGraveyard = TableUtils.shallowCopy(self._entityGraveyard);
	local componentGraveyard = TableUtils.shallowCopy(self._componentGraveyard);
	local entityNursery = TableUtils.shallowCopy(self._entityNursery);
	local componentNursery = TableUtils.shallowCopy(self._componentNursery);

	self._entityGraveyard = {};
	self._componentGraveyard = {};
	self._entityNursery = {};
	self._componentNursery = {};

	for entity, components in pairs(componentGraveyard) do
		for class, component in pairs(components) do
			unregisterComponent(self, entity, component);
		end
	end

	for entity in pairs(entityGraveyard) do
		unregisterEntity(self, entity);
	end

	for entity in pairs(entityNursery) do
		registerEntity(self, entity);
	end

	for entity, components in pairs(componentNursery) do
		for class, component in pairs(components) do
			registerComponent(self, entity, component);
		end
	end

	updateQueries(self, entityNursery, entityGraveyard, componentNursery, componentGraveyard);
end

ECS.runSystems = function(self, event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			system[event](system, ...);
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
end

-- TODO error on duplicate class
ECS.addComponent = function(self, entity, component)
	assert(component);
	assert(component:isInstanceOf(Component));
	local nursery = self._componentNursery[entity];
	if not nursery then
		nursery = {};
		self._componentNursery[entity] = nursery;
	end
	nursery[component:getClass()] = component;
end

ECS.removeComponent = function(self, entity, component)
	assert(component);
	assert(component:isInstanceOf(Component));
	local nursery = self._componentNursery[entity];
	if nursery and nursery[component:getClass()] then
		nursery[component:getClass()] = nil;
	else
		local graveyard = self._componentGraveyard[entity];
		if not graveyard then
			graveyard = {};
			self._componentGraveyard[entity] = graveyard;
		end
		graveyard[component:getClass()] = component;
	end
end

ECS.addQuery = function(self, query)
	assert(#self._entities == 0);
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

-- ACCESSORS

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

ECS.getComponent = function(self, entity, class)
	assert(entity);
	assert(class);
	if self._entityToComponent[entity] then
		local exactMatch = self._entityToComponent[entity][class];
		if exactMatch then
			return exactMatch;
		end
		local derivedMatches = self._entityToComponents[entity][class];
		if derivedMatches then
			assert(TableUtils.countKeys(self._entityToComponents[entity][class]) <= 1); -- Ambiguous call
			for component in pairs(derivedMatches) do
				return component;
			end
		end
	end
end

ECS.getComponents = function(self, entity, baseClass)
	local allComponents = self._entityToComponents[entity];
	if not allComponents then
		return {};
	end
	local components = allComponents[baseClass];
	if not components then
		return {};
	end
	return TableUtils.shallowCopy(components);
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

return ECS;
