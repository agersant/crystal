local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");

local tests = {};

tests[#tests + 1] = {name = "Add and remove entity"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	ecs:update(0);
	assert(ecs:getAllEntities()[a]);
	assert(ecs:getAllEntities()[b]);

	ecs:despawn(b);
	ecs:update(0);
	assert(ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);

	ecs:despawn(a);
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);
end

tests[#tests + 1] = {name = "Add and remove component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local c = Snoot:new();
	a:addComponent(c);
	assert(a:getComponent(Snoot) == c);
	assert(b:getComponent(Snoot) == nil);
	ecs:update();
	assert(ecs:getAllEntitiesWith(Snoot)[a]);
	assert(not ecs:getAllEntitiesWith(Snoot)[b]);
	assert(c:getEntity() == a);

	a:removeComponent(c);
	assert(nil == a:getComponent(Snoot));
	assert(nil == b:getComponent(Snoot));
	assert(not ecs:getAllEntitiesWith(Snoot)[a]);
	assert(not ecs:getAllEntitiesWith(Snoot)[b]);
	assert(c:getEntity() == nil);
end

tests[#tests + 1] = {name = "Get entities with component"};
tests[#tests].body = function()
	Class:resetIndex();

	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);

	local Snoot = Class("Snoot", Component);
	local Boop = Class("Boop", Snoot);
	local boop = Boop:new();
	a:addComponent(boop);
	ecs:update();
	assert(ecs:getAllEntitiesWith(Snoot)[a] == boop);
	assert(ecs:getAllComponents(Snoot)[1] == boop);
	a:removeComponent(boop);
	assert(not ecs:getAllEntitiesWith(Snoot)[a]);
	assert(#ecs:getAllComponents(Snoot) == 0);
end

-- TODO test activate calls

-- TODO test queries

-- TODO test systems

return tests;
