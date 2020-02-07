require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");
local Component = require("engine/ecs/Component");
local System = require("engine/ecs/System");
local Query = require("engine/ecs/query/Query");

local ECS = Class("ECS");

ECS.init = function(self)
	self._entities = {};
	self._entityToComponents = {};

	self._componentToEntity = {};
	self._componentClassToEntities = {};

	self._queries = {};
	self._componentClassToQueries = {};
	self._queryToEntities = {};

	self._systems = {};
end

ECS.update = function(self, dt)
	for system in pairs(self._systems) do
		system:update(dt);
	end
end

ECS.spawn = function(self, class, ...)
	assert(class);
	local entity = class:new(self, ...);
	assert(entity);
	self._entities[entity] = true;
	self._entityToComponents[entity] = {};
	entity:setIsValid(true);
	return entity;
end

ECS.despawn = function(self, entity)
	assert(entity);
	assert(self._entities[entity]);
	assert(self._entityToComponents[entity]);
	local components = TableUtils.shallowCopy(self._entityToComponents[entity]);
	for class, component in pairs(components) do
		self:removeComponent(component);
	end
	self._entities[entity] = nil;
	self._entityToComponents[entity] = nil;
	entity:setIsValid(false);
end

ECS.addComponent = function(self, entity, component)
	assert(entity);
	assert(entity:isValid());
	assert(component);
	assert(component:isInstanceOf(Component));

	local class = component:getClass();
	assert(class);
	if not self._componentClassToEntities[class] then
		self._componentClassToEntities[class] = {};
	end

	assert(not self._componentToEntity[component]);
	self._componentToEntity[component] = entity;

	assert(self._entityToComponents[entity]);
	self._entityToComponents[entity][class] = component;

	assert(not self._componentClassToEntities[class][entity]);
	self._componentClassToEntities[class][entity] = true;

	if self._componentClassToQueries[class] then
		for query in pairs(self._componentClassToQueries[class]) do
			if query:matches(entity) then
				self._queryToEntities[query][entity] = true;
			end
		end
	end
end

ECS.removeComponent = function(self, entity, component)
	assert(entity);
	assert(entity:isValid());
	assert(component);

	local class = component:getClass();
	assert(class);

	assert(self._componentToEntity[component]);
	self._componentToEntity[component] = nil;

	assert(self._entityToComponents[entity][class]);
	self._entityToComponents[entity][class] = nil;

	assert(self._componentClassToEntities[class][entity]);
	self._componentClassToEntities[class][entity] = nil;

	if self._componentClassToQueries[class] then
		for query in pairs(self._componentClassToQueries[class]) do
			if not query:matches(entity) then
				self._queryToEntities[query][entity] = nil;
			end
		end
	end
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
	self._systems[system] = true;
end

-- ACCESSORS

ECS.getEntity = function(self, component)
	assert(component);
	return self._componentToEntity[component];
end

ECS.getAllEntities = function(self)
	return TableUtils.shallowCopy(self._entities);
end

ECS.getAllEntitiesWith = function(self, class)
	assert(class);
	local source = self._componentClassToEntities[class] or {};
	local output = {};
	for entity, _ in pairs(source) do
		output[entity] = true;
	end
	return output;
end

ECS.query = function(self, query)
	return TableUtils.shallowCopy(self._queryToEntities[query]);
end

ECS.getComponent = function(self, entity, class)
	assert(entity);
	assert(entity:isValid());
	assert(class);
	return self._entityToComponents[entity][class];
end

return ECS;
