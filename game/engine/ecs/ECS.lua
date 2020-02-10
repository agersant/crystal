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
		if not self._componentClassToEntities[baseClass][entity] then
			self._componentClassToEntities[baseClass][entity] = {};
		end
		assert(not self._componentClassToEntities[baseClass][entity][component]);
		self._componentClassToEntities[baseClass][entity][component] = true;

		if self._componentClassToQueries[baseClass] then
			for query in pairs(self._componentClassToQueries[baseClass]) do
				if query:matches(entity) then
					if not self._queryToEntities[query][entity] then
						query:onMatchEntity(entity);
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
		self._entityToComponents[entity][baseClass][component] = nil;
		if TableUtils.countKeys(self._entityToComponents[entity][baseClass]) == 0 then
			self._entityToComponents[entity][baseClass] = nil;
		end

		assert(self._componentClassToEntities[baseClass][entity][component]);
		self._componentClassToEntities[baseClass][entity][component] = nil;
		if TableUtils.countKeys(self._componentClassToEntities[baseClass][entity]) == 0 then
			self._componentClassToEntities[baseClass][entity] = nil;
		end

		if self._componentClassToQueries[baseClass] then
			for query in pairs(self._componentClassToQueries[baseClass]) do
				if not query:matches(entity) then
					if self._queryToEntities[query][entity] then
						query:onUnmatchEntity(entity);
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
	self._queryToComponents = {};

	self._systems = {};

	self._entityNursery = {};
	self._entityGraveyard = {};
	self._componentNursery = {};
	self._componentGraveyard = {};
end

ECS.update = function(self)
	for query in pairs(self._queries) do
		query:flush();
	end

	local graveyard = TableUtils.shallowCopy(self._componentGraveyard);
	self._componentGraveyard = {};
	for entity, components in pairs(graveyard) do
		for class, component in pairs(components) do
			unregisterComponent(self, entity, component);
		end
	end

	local graveyard = TableUtils.shallowCopy(self._entityGraveyard);
	self._entityGraveyard = {};
	for entity in pairs(graveyard) do
		unregisterEntity(self, entity);
	end

	local nursery = TableUtils.shallowCopy(self._entityNursery);
	self._entityNursery = {};
	for entity, components in pairs(nursery) do
		registerEntity(self, entity, components);
	end

	local nursery = TableUtils.shallowCopy(self._componentNursery);
	self._componentNursery = {};
	for entity, components in pairs(nursery) do
		for class, component in pairs(components) do
			registerComponent(self, entity, component);
		end
	end
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
	component:setEntity(entity);
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
	component:setEntity(nil);
end

ECS.addQuery = function(self, query)
	assert(#self._entities == 0);
	assert(not self._queries[query]);
	assert(query:isInstanceOf(Query));
	self._queries[query] = true;
	self._queryToEntities[query] = {};
	self._queryToComponents[query] = {};
	for _, class in pairs(query:getClasses()) do
		local baseClass = class;
		while baseClass ~= Component do
			self._queryToComponents[query][baseClass] = {};
			if not self._componentClassToQueries[baseClass] then
				self._componentClassToQueries[baseClass] = {};
			end
			self._componentClassToQueries[baseClass][query] = true;
			baseClass = baseClass.super;
		end
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

ECS.query = function(self, query)
	return TableUtils.shallowCopy(self._queryToEntities[query]);
end

-- TODO support base class, multiple outputs
ECS.getComponent = function(self, entity, class)
	assert(entity);
	assert(class);
	if self._entityNursery[entity] then
		if self._componentNursery[entity] then
			return self._componentNursery[entity][class];
		end
	else
		assert(entity:isValid());
		if self._componentNursery[entity] then
			return self._componentNursery[entity][class];
		elseif self._componentGraveyard[entity] then
			local component = self._entityToComponents[entity][class];
			if component ~= self._componentGraveyard[entity][class] then
				return component;
			end
		else
			return self._entityToComponents[entity][class];
		end
	end
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
