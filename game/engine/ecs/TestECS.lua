local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");
local System = require("engine/ecs/System");

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
	local b = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local snoot = Snoot:new();
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == snoot);
	assert(b:getComponent(Snoot) == nil);
	ecs:update();
	assert(ecs:getAllEntitiesWith(Snoot)[a]);
	assert(not ecs:getAllEntitiesWith(Snoot)[b]);
	assert(snoot:getEntity() == a);

	a:removeComponent(snoot);
	assert(nil == a:getComponent(Snoot));
	assert(nil == b:getComponent(Snoot));
	assert(ecs:getAllEntitiesWith(Snoot)[a]);
	ecs:update();
	assert(not ecs:getAllEntitiesWith(Snoot)[a]);
	assert(not ecs:getAllEntitiesWith(Snoot)[b]);
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
	assert(a:getComponent(Snoot) == snoot);
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
	assert(a:getComponent(Snoot) == snoot);
	a:removeComponent(snoot);
	assert(a:getComponent(Snoot) == nil);
	a:addComponent(snoot);
	assert(a:getComponent(Snoot) == snoot);
	ecs:update();
	assert(a:getComponent(Snoot) == snoot);
	assert(activated);
end

tests[#tests + 1] = {name = "Get entities with component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(ecs:getAllEntitiesWith(Snoot)[a] == boop);
	assert(ecs:getAllComponents(Snoot)[1] == boop);
	a:removeComponent(boop);
	ecs:update();
	assert(not ecs:getAllEntitiesWith(Snoot)[a]);
	assert(#ecs:getAllComponents(Snoot) == 0);
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

-- TODO test queries

return tests;
