local ECS = require("engine/ecs/ECS");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");

local tests = {};

tests[#tests + 1] = {name = "Add and remove entity"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);
	assert(ecs:getAllEntities()[a]);
	assert(ecs:getAllEntities()[b]);

	ecs:despawn(b);
	assert(ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);

	ecs:despawn(a);
	assert(not ecs:getAllEntities()[a]);
	assert(not ecs:getAllEntities()[b]);
end

tests[#tests + 1] = {name = "Add and remove component"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	local b = ecs:spawn(Entity);

	local c = Component:new(ecs);
	a:addComponent(c);
	assert(a:getComponent(Component) == c);
	assert(b:getComponent(Component) == nil);
	assert(ecs:getAllEntitiesWith(Component)[a]);
	assert(not ecs:getAllEntitiesWith(Component)[b]);
	assert(ecs:getEntity(c) == a);

	a:removeComponent(c);
	assert(nil == a:getComponent(Component));
	assert(nil == b:getComponent(Component));
	assert(not ecs:getAllEntitiesWith(Component)[a]);
	assert(not ecs:getAllEntitiesWith(Component)[b]);
	assert(ecs:getEntity(c) == nil);
end

-- TODO test queries

-- TODO test systems

return tests;
