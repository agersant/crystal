local Padding = require("ui/bricks/core/Padding");
local BasicJoint = require("ui/bricks/core/BasicJoint");
local Wrapper = require("modules/ui/wrapper");

local WidgetJoint = Class("WidgetJoint", BasicJoint);
local Widget = Class("Widget", Wrapper);

WidgetJoint.init = function(self, parent, child)
	WidgetJoint.super.init(self, parent, child);
	self._horizontalAlignment = "stretch";
	self._verticalAlignment = "stretch";
end

Widget.init = function(self)
	Widget.super.init(self, WidgetJoint);
	self._script = crystal.Script:new();
	self._script:add_alias(self);
end

Widget.script = function(self)
	return self._script;
end

Widget.setRoot = Widget.super.set_child;

Widget.compute_desired_size = function(self)
	if self._child then
		local childWidth, childHeight = self._child:desired_size();
		return self.child_joint:compute_desired_size(childWidth, childHeight);
	end
	return 0, 0;
end

Widget.update = function(self, dt)
	self._script:update(dt);
	Widget.super.update(self, dt);
end

Widget.arrange_child = function(self)
	if self._child then
		local width, height = self:size();
		local childWidth, childHeight = self._child:desired_size();
		local left, right, top, bottom = self.child_joint:computeLocalPosition(childWidth, childHeight, width, height);
		self._child:set_relative_position(left, right, top, bottom);
	end
end

--#region Tests

crystal.test.add("Runs scripts", function()
	local widget = Widget:new();
	local sentinel;
	widget:script():add_thread(function()
		sentinel = 1;
	end);
	assert(sentinel == nil);
	widget:update(0);
	assert(sentinel == 1);
end);

--#endregion

return Widget;
