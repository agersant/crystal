local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local WorldWidget = require("mapscene/display/WorldWidget");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local WorldWidgetSystem = Class("WorldWidgetSystem", System);

WorldWidgetSystem.init = function(self, ecs)
	WorldWidgetSystem.super.init(self, ecs);
	self._bodyQuery = AllComponents:new({ WorldWidget, PhysicsBody });
	self:getECS():addQuery(self._bodyQuery);
end

WorldWidgetSystem.afterScripts = function(self, dt)
	local entities = self._bodyQuery:getEntities();
	for entity in pairs(entities) do
		local WorldWidget = entity:getComponent(WorldWidget);
		local physicsBody = entity:getComponent(PhysicsBody);
		local x, y = physicsBody:getPosition();
		WorldWidget:setWidgetPosition(x, y);
		WorldWidget:setZOrder(math.huge);
	end

	local worldWidgets = self:getECS():getAllComponents(WorldWidget);
	for _, worldWidget in ipairs(worldWidgets) do
		worldWidget:updateWidget(dt);
	end
end

return WorldWidgetSystem;
