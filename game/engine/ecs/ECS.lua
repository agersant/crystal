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

	local baseClass = class;
	while baseClass ~= Component do
		assert(self._entityToComponents[entity]);
		self._entityToComponents[entity][baseClass] = component;

		if not self._componentClassToEntities[baseClass] then
			self._componentClassToEntities[baseClass] = {};
		end
		assert(not self._componentClassToEntities[baseClass][entity]);
		self._componentClassToEntities[baseClass][entity] = true;

		if self._componentClassToQueries[baseClass] then
			for query in pairs(self._componentClassToQueries[baseClass]) do
				if query:matches(entity) then
					if not self._queryToEntities[query][entity] then
						query:onMatch(entity);
						self._queryToEntities[query][entity] = true;
					end
				end
			end
		end

		baseClass = baseClass.super;
	end

	component:activate();
end

local unregisterComponent = function(self, entity, component)
	assert(entity);
	assert(entity:isValid());
	assert(component);

	component:deactivate();

	local class = component:getClass();
	assert(class);

	local baseClass = class;
	while baseClass ~= Component do
		assert(self._entityToComponents[entity][baseClass]);
		self._entityToComponents[entity][baseClass] = nil;

		assert(self._componentClassToEntities[baseClass][entity]);
		self._componentClassToEntities[baseClass][entity] = nil;

		if self._componentClassToQueries[baseClass] then
			for query in pairs(self._componentClassToQueries[baseClass]) do
				if not query:matches(entity) then
					if self._queryToEntities[query][entity] then
						query:onUnmatch(entity);
						self._queryToEntities[query][entity] = nil;
					end
				end
			end
		end

		baseClass = baseClass.super;
	end

end

local registerEntity = function(self, entity, components)
	entity:setIsValid(true);
	assert(not self._entities[entity]);
	self._entities[entity] = true;
	self._entityToComponents[entity] = {};
	for class, component in pairs(components) do
		registerComponent(self, entity, component);
	end
end

local unregisterEntity = function(self, entity)
	assert(self._entityToComponents[entity]);
	local components = TableUtils.shallowCopy(self._entityToComponents[entity]);
	for _, component in pairs(components) do
		unregisterComponent(self, entity, component);
	end
	assert(self._entities[entity]);
	self._entities[entity] = nil;
	self._entityToComponents[entity] = nil;
	entity:setIsValid(false);
end

ECS.init = function(self)
	self._entities = {};
	self._entityToComponents = {};
	self._componentClassToEntities = {};

	self._queries = {};
	self._componentClassToQueries = {};
	self._queryToEntities = {};

	self._systems = {};

	self._nursery = {};
	self._graveyard = {};
end

ECS.update = function(self)
	for query in pairs(self._queries) do
		query:flush();
	end

	local graveyard = TableUtils.shallowCopy(self._graveyard);
	self._graveyard = {};
	for entity in pairs(graveyard) do
		unregisterEntity(self, entity);
	end

	local nursery = TableUtils.shallowCopy(self._nursery);
	self._nursery = {};
	for entity, components in pairs(nursery) do
		registerEntity(self, entity, components);
	end
end

ECS.emit = function(self, event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			system[event](system, ...);
		end
	end
end

ECS.spawn = function(self, class, ...)
	assert(class);
	local entity = {};
	self._nursery[entity] = {};
	class:placementNew(entity, self, ...);
	return entity;
end

ECS.despawn = function(self, entity)
	assert(entity);
	if self._nursery[entity] then
		self._nursery[entity] = nil;
	else
		assert(self._entities[entity]);
		self._graveyard[entity] = true;
	end
end

ECS.addComponent = function(self, entity, component)
	local nurseryComponents = self._nursery[entity];
	if nurseryComponents then
		assert(component);
		assert(component:isInstanceOf(Component));
		nurseryComponents[component:getClass()] = component;
	else
		registerComponent(self, entity, component);
	end
	component:setEntity(entity);
end

ECS.removeComponent = function(self, entity, component)
	local nurseryComponents = self._nursery[entity];
	if nurseryComponents then
		nurseryComponents[component] = nil;
	else
		unregisterComponent(self, entity, component);
	end
	component:setEntity(nil);
end

ECS.addQuery = function(self, query)
	assert(#self._entities == 0);
	assert(not self._queries[query]);
	assert(query:isInstanceOf(Query));
	self._queries[query] = true;
	self._queryToEntities[query] = {};
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
	for entity, _ in pairs(source) do
		output[entity] = self._entityToComponents[entity][class];
	end
	return output;
end

ECS.query = function(self, query)
	return TableUtils.shallowCopy(self._queryToEntities[query]);
end

ECS.getComponent = function(self, entity, class)
	assert(entity);
	assert(class);
	local nurseryComponents = self._nursery[entity];
	if nurseryComponents then
		return nurseryComponents[class];
	else
		assert(entity:isValid());
		return self._entityToComponents[entity][class];
	end
end

ECS.getAllComponents = function(self, class)
	assert(class);
	local source = self._componentClassToEntities[class] or {};
	local output = {};
	for entity, _ in pairs(source) do
		table.insert(output, self._entityToComponents[entity][class]);
	end
	return output;
end

return ECS;
