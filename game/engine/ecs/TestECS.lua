local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");

local tests = {};

tests[#tests + 1] = {name = "Spawn and despawn entity"};
tests[#tests].body = function()
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
end

tests[#tests + 1] = {name = "Spawn and despawn entity between updates"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	assert(not ecs:getAllEntities()[a]);
	ecs:despawn(a);
	assert(not ecs:getAllEntities()[a]);
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
end

tests[#tests + 1] = {name = "Add and remove component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local snoot = Snoot:new();
	a:addComponent(snoot);
	ecs:update();
	assert(snoot:getEntity() == a);

	a:removeComponent(snoot);
	assert(snoot:getEntity() == a);
	ecs:update();
	assert(snoot:getEntity() == nil);
end

tests[#tests + 1] = {name = "Add and remove component between updates"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();
	local Snoot = Class("Snoot", Component);

	local a = ecs:spawn(Entity);
	local snoot = Snoot:new();
	snoot.activate = function()
		error("unexpected activation")
	end
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	a:removeComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	ecs:update();
	assert(a:getComponent(Snoot) == nil);

	local a = ecs:spawn(Entity);
	local snoot = Snoot:new();
	local activated = false;
	snoot.activate = function()
		activated = true;
	end
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	a:removeComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	ecs:update();
	assert(a:getComponent(Snoot) == snoot);
	assert(activated);
end

tests[#tests + 1] = {name = "Get component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();
	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local Bonk = Class("Bonk", Snoot);
	local boop = Boop:new();
	local bonk = Bonk:new();

	a:addComponent(boop);
	assert(a:getComponent(Boop) == nil);
	assert(a:getComponent(Snoot) == nil);

	ecs:update();
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Snoot) == boop);

	a:addComponent(bonk);
	assert(a:getComponent(Boop) == boop);
	assert(a:getComponent(Snoot) == boop);

	ecs:update();
	local success = pcall(function()
		a:getComponent(Snoot);
	end);
	assert(not success);
	assert(a:getComponent(Boop) == boop);

	a:removeComponent(boop);
	ecs:update();
	assert(a:getComponent(Boop) == nil);
	assert(a:getComponent(Snoot) == bonk);
end

tests[#tests + 1] = {name = "Get components"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	assert(not a:getComponents(Snoot)[boop]);
	ecs:update();
	assert(a:getComponents(Snoot)[boop]);
	a:removeComponent(boop);
	assert(a:getComponents(Snoot)[boop]);
	ecs:update();
	assert(not a:getComponents(Snoot)[boop]);
end

tests[#tests + 1] = {name = "Get all entities with component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(ecs:getAllEntitiesWith(Snoot)[a]);
	a:removeComponent(boop);
	ecs:update();
	assert(not ecs:getAllEntitiesWith(Snoot)[a]);
end

tests[#tests + 1] = {name = "Get all components"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
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
end

tests[#tests + 1] = {name = "Activation lifecycle"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local activated = false;
	local Snoot = Class("Snoot", Component);
	Snoot.activate = function(self)
		activated = true;
	end
	Snoot.deactivate = function(self)
		activated = false;
	end

	local a = ecs:spawn(Entity);
	local snoot = Snoot:new();

	a:addComponent(snoot);
	assert(not activated);

	ecs:update();
	assert(activated);

	a:removeComponent(snoot);
	assert(activated);
	ecs:update();
	assert(not activated);

	a:addComponent(snoot);
	assert(not activated);
	ecs:update();
	assert(activated);

	a:despawn();
	assert(activated);

	ecs:update();
	assert(not activated);
end

tests[#tests + 1] = {name = "Systems update in correct order"};
tests[#tests].body = function()
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
	ecs:runSystems("randomEvent");
	assert(sentinel == 0);
	ecs:runSystems("update");
	assert(sentinel == 10);
end

tests[#tests + 1] = {name = "Systems receive parameters"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local ran = false;
	local system = System:new(ecs);
	system.update = function(self, value)
		assert(self == system);
		assert(value);
		ran = true;
	end
	ecs:addSystem(system);
	ecs:runSystems("update", true);
	assert(ran);
end

tests[#tests + 1] = {name = "Query maintains list of entities"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();
	local Snoot = Class("Snoot", Component);
	local query = AllComponents:new({Snoot});
	ecs:addQuery(query);

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	local c = ecs:spawn(Entity);
	local snoot = Snoot:new();
	b:addComponent(snoot);
	assert(not ecs:query(query)[a]);
	assert(not ecs:query(query)[b]);
	assert(not ecs:query(query)[c]);

	ecs:update();
	assert(not ecs:query(query)[a]);
	assert(ecs:query(query)[b]);
	assert(not ecs:query(query)[c]);

	b:removeComponent(snoot);
	assert(not ecs:query(query)[a]);
	assert(ecs:query(query)[b]);
	assert(not ecs:query(query)[c]);

	ecs:update();
	assert(not ecs:query(query)[a]);
	assert(not ecs:query(query)[b]);
	assert(not ecs:query(query)[c]);
end

tests[#tests + 1] = {name = "Query entity list captures derived components"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();
	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local query = AllComponents:new({Snoot});
	ecs:addQuery(query);

	local a = ecs:spawn(Entity);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(ecs:query(query)[a]);

	a:removeComponent(boop);
	ecs:update();
	assert(not ecs:query(query)[a]);
end

tests[#tests + 1] = {name = "Query maintains changelog of entities"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();
	local Snoot = Class("Snoot", Component);
	local query = AllComponents:new({Snoot});
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
end

return tests;
