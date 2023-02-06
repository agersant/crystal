local Entity = require("ecs/Entity");
local MapScene = require("mapscene/MapScene");
local WorldWidget = require("mapscene/display/WorldWidget");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local Image = require("ui/bricks/elements/Image");

local tests = {};

tests[#tests + 1] = { name = "Draws widget", gfx = "on" };
tests[#tests].body = function(context)
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	local widget = Image:new();
	widget:setImageSize(48, 32);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entity:addComponent(WorldWidget:new(widget));
	entity:setPosition(160, 120);

	scene:update(0);
	scene:draw();
	context:compareFrame("test-data/TestWorldWidget/draws-widget.png");
end

return tests;
