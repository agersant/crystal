local WorldWidget = require("mapscene/display/WorldWidget");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local WorldWidgetSystem = Class("WorldWidgetSystem", crystal.System);

WorldWidgetSystem.init = function(self)
	self.with_widget = self:add_query({ WorldWidget });
	self.with_body = self:add_query({ WorldWidget, PhysicsBody });
end

WorldWidgetSystem.afterScripts = function(self, dt)
	local entities = self.with_body:entities();
	for entity in pairs(entities) do
		local body = entity:component(PhysicsBody);
		local x, y = body:getPosition();
		for widget in pairs(entity:components(WorldWidget)) do
			widget:setWidgetPosition(x, y);
			widget:setZOrder(math.huge);
		end
	end

	local entities = self.with_widget:entities();
	for entity in pairs(entities) do
		for widget in pairs(entity:components(WorldWidget)) do
			widget:updateWidget(dt);
		end
	end
end

return WorldWidgetSystem;
