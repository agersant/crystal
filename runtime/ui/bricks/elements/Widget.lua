local Joint = require("ui/bricks/core/Joint");
local Padding = require("ui/bricks/core/Padding");
local Wrapper = require("ui/bricks/core/Wrapper");
local BasicJoint = require("ui/bricks/core/BasicJoint");
local Alias = require("utils/Alias");
local TableUtils = require("utils/TableUtils");

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
	Alias:add(self._script, self);
end

Widget.script = function(self)
	return self._script;
end

Widget.setRoot = Widget.super.setChild;

Widget.computeDesiredSize = function(self)
	if self._child then
		local childWidth, childHeight = self._child:getDesiredSize();
		return self._childJoint:computeDesiredSize(childWidth, childHeight);
	end
	return 0, 0;
end

Widget.update = function(self, dt)
	self._script:update(dt);
	Widget.super.update(self, dt);
end

Widget.arrangeChild = function(self)
	if self._child then
		local width, height = self:getSize();
		local childWidth, childHeight = self._child:getDesiredSize();
		local left, right, top, bottom = self._childJoint:computeLocalPosition(childWidth, childHeight, width, height);
		self._child:setLocalPosition(left, right, top, bottom);
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
