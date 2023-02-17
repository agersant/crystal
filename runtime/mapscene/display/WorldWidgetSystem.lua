local WorldWidget = require("mapscene/display/WorldWidget");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local WorldWidgetSystem = Class("WorldWidgetSystem", crystal.System);

WorldWidgetSystem.init = function(self, ecs)
	WorldWidgetSystem.super.init(self, ecs);
	self._query = self:add_query({ WorldWidget, PhysicsBody });
end

WorldWidgetSystem.afterScripts = function(self, dt)
	local entities = self._query:entities();
	for entity in pairs(entities) do
		local WorldWidget = entity:component(WorldWidget);
		local physicsBody = entity:component(PhysicsBody);
		local x, y = physicsBody:getPosition();
		WorldWidget:setWidgetPosition(x, y);
		WorldWidget:setZOrder(math.huge);
	end

	local worldWidgets = self:ecs():components(WorldWidget);
	for _, worldWidget in ipairs(worldWidgets) do
		worldWidget:updateWidget(dt);
	end
end

return WorldWidgetSystem;
