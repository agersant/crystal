require("engine/utils/OOP");
local Script = require("engine/script/Script");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local Joint = require("engine/ui/bricks/core/Joint");
local Padding = require("engine/ui/bricks/core/Padding");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Wrapper = require("engine/ui/bricks/core/Wrapper");
local BasicJoint = require("engine/ui/bricks/core/BasicJoint");
local Alias = require("engine/utils/Alias");
local TableUtils = require("engine/utils/TableUtils");

local WidgetJoint = Class("WidgetJoint", BasicJoint);
local Widget = Class("Widget", Wrapper);

WidgetJoint.init = function(self, parent, child)
	WidgetJoint.super.init(self, parent, child);
	self._horizontalAlignment = HorizontalAlignment.STRETCH;
	self._verticalAlignment = VerticalAlignment.STRETCH;
end

Widget.init = function(self)
	Widget.super.init(self, WidgetJoint);
	self._scripts = {};
end

Widget.setRoot = Widget.super.setChild;

Widget.addScript = function(self, script)
	assert(script);
	assert(script:isInstanceOf(Script));
	self._scripts[script] = true;
	Alias:add(script, self);
	return script;
end

Widget.removeScript = function(self, script)
	assert(script);
	assert(script:isInstanceOf(Script));
	Alias:remove(script, self);
	self._scripts[script] = nil;
end

Widget.computeDesiredSize = function(self)
	local width, height = 0, 0;
	if self._child then
		local childWidth, childHeight = self._child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = self._childJoint:getEachPadding();
		width = childWidth + paddingLeft + paddingRight;
		height = childHeight + paddingTop + paddingBottom;
	end
	return math.max(width, 0), math.max(height, 0);
end

Widget.update = function(self, dt)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for script in pairs(scripts) do
		script:update(dt);
	end
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

return Widget;
