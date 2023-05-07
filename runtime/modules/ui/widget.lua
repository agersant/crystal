local BasicJoint = require(CRYSTAL_RUNTIME .. "/modules/ui/basic_joint");
local Wrapper = require(CRYSTAL_RUNTIME .. "/modules/ui/wrapper");

---@class Widget : Wrapper
---@field private _script Script
local Widget = Class("Widget", Wrapper);

Widget.init = function(self)
	Widget.super.init(self, BasicJoint);
	self._script = crystal.Script:new();
	self._script:add_alias(self);
end

---@return Script
Widget.script = function(self)
	return self._script;
end

---@protected
---@return number
---@return number
Widget.compute_desired_size = function(self)
	if self._child then
		local child_width, child_height = self._child:desired_size();
		return self.child_joint:compute_desired_size(child_width, child_height);
	end
	return 0, 0;
end

---@protected
---@param dt number
Widget.update = function(self, dt)
	Widget.super.update(self, dt);
	self._script:update(dt);
end

---@protected
Widget.arrange_child = function(self)
	if self._child then
		local width, height = self:size();
		local child_width, child_height = self._child:desired_size();
		local left, right, top, bottom = self.child_joint:compute_relative_position(child_width, child_height, width,
			height);
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
