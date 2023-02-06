local Script = require("script/Script");
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
	if self._child then
		local childWidth, childHeight = self._child:getDesiredSize();
		return self._childJoint:computeDesiredSize(childWidth, childHeight);
	end
	return 0, 0;
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
