local WorldWidget = require("mapscene/display/WorldWidget");

local WorldWidgetSystem = Class("WorldWidgetSystem", crystal.System);

WorldWidgetSystem.init = function(self)
	self.with_widget = self:add_query({ WorldWidget });
	self.with_body = self:add_query({ WorldWidget, crystal.Body });
end

WorldWidgetSystem.after_run_scripts = function(self, dt)
	for entity in pairs(self.with_body:entities()) do
		local body = entity:component(crystal.Body);
		local x, y = body:position();
		for widget in pairs(entity:components(WorldWidget)) do
			widget:setWidgetPosition(x, y);
			widget:setZOrder(math.huge);
		end
	end

	for widget in pairs(self.with_widget:components()) do
		widget:updateWidget(dt);
	end
end

return WorldWidgetSystem;
