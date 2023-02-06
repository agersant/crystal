local ECS = require("ecs/ECS");
local Component = require("ecs/Component");
local Entity = require("ecs/Entity");
local Event = require("ecs/Event");
local System = require("ecs/System");
local EitherComponent = require("ecs/query/EitherComponent");
local AllComponents = require("ecs/query/AllComponents");
local TableUtils = require("utils/TableUtils");

local tests = {};

tests[#tests + 1] = { name = "Spawn and despawn entity" };
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

tests[#tests + 1] = { name = "Spawn and despawn entity between updates" };
tests[#tests].body = function()
	local ecs = ECS:new();

	local a = ecs:spawn(Entity);
	assert(not ecs:getAllEntities()[a]);
	ecs:despawn(a);
	assert(not ecs:getAllEntities()[a]);
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
end

tests[#tests + 1] = { name = "Add and remove component" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Add and remove component between updates" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cannot add component to despawned entity" };
tests[#tests].body = function()
	local ecs = ECS:new();
	local a = ecs:spawn(Entity);
	ecs:update(0);
	a:addComponent(Component:new());
	a:despawn();
	ecs:update(0);
	assert(not ecs:getAllEntities()[a]);
	assert(not a:getExactComponent(Component));
end

tests[#tests + 1] = { name = "Transfer component" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Prevent duplicate components" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get exact component" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get component" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get components" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get all entities with component" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get all components" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Despawned entities don't leave components behind" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Get system" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Systems run when notified" };
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
	ecs:notifySystems("randomEvent");
	assert(sentinel == 0);
	ecs:notifySystems("update");
	assert(sentinel == 10);
end

tests[#tests + 1] = { name = "Systems receive parameters" };
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
	ecs:notifySystems("update", true);
	assert(ran);
end

tests[#tests + 1] = { name = "Query maintains list of entities" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query entity list captures derived components" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query maintains changelog of entities" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query maintains changelog of components" };
tests[#tests].body = function()
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
	assert(TableUtils.equals({ [compA] = a, [compB] = a }, query:getAddedComponents(BaseComp)));

	a:addComponent(compC);
	ecs:update();
	assert(TableUtils.equals({ [compC] = a }, query:getAddedComponents(BaseComp)));

	a:removeComponent(compA);
	ecs:update();
	assert(TableUtils.equals({ [compA] = a }, query:getRemovedComponents(BaseComp)));
end

tests[#tests + 1] = { name = "Changelog of components is updated when entity despawns" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query component changelog works when component is added and removed between updates" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query component changelog works for intersection query" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Query component changelog works for union query" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Events can be retrieved within the rest of the frame" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Events can be retrieved by base class" };
tests[#tests].body = function()
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
end

return tests;
