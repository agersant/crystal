require("engine/utils/OOP");
local Script = require("engine/script/Script");
local Joint = require("engine/ui/bricks/core/Joint");
local Wrapper = require("engine/ui/bricks/core/Wrapper");
local TableUtils = require("engine/utils/TableUtils");

local WidgetJoint = Class("WidgetJoint", Joint);
local Widget = Class("Widget", Wrapper);

Widget.init = function(self)
	Widget.super.init(self, WidgetJoint);
	self._scripts = {};
end

Widget.setRoot = Widget.super.setChild;

Widget.addScript = function(self, script)
	assert(script);
	assert(script:isInstanceOf(Script));
	self._scripts[script] = true;
	return script;
end

Widget.removeScript = function(self, script)
	assert(script);
	assert(script:isInstanceOf(Script));
	self._scripts[script] = nil;
end

Widget.update = function(self, dt)
	local scripts = TableUtils.shallowCopy(self._scripts);
	for script in pairs(scripts) do
		script:update(dt);
	end
	Widget.super.update(self, dt);
end

return Widget;
