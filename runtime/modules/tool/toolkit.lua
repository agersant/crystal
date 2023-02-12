local features = require("features");
local Tool = require("modules/tool/tool");

local Toolkit = Class("Toolkit");

if not features.tools then
	features.stub(Toolkit);
end

Toolkit.init = function(self)
	self.tools = {};
	self.keybinds = {};
	self.visible_tools = {};
end

Toolkit.add = function(self, tool, options)
	assert(tool:is_instance_of(Tool));
	self.tools[tool:class_name()] = tool;
	if options then
		if options.keybind then
			self.keybinds[options.keybind] = tool;
		end
	end
end

Toolkit.show = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool] = true;
end

Toolkit.hide = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool] = nil;
end

Toolkit.is_visible = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	return self.visible_tools[tool];
end

Toolkit.update = function(self, dt)
	for _, tool in pairs(self.tools) do
		tool:update(dt);
	end
end

Toolkit.draw = function(self)
	for tool, _ in pairs(self.visible_tools) do
		tool:draw();
	end
end

Toolkit.key_pressed = function(self, key, scanCode, isRepeat)
	for tool, _ in pairs(self.visible_tools) do
		tool:key_pressed(key, scanCode, isRepeat);
	end

	local tool = self.keybinds[key];
	if tool then
		if tool:is_visible() then
			tool:hide();
		else
			tool:show();
		end
	end
end

Toolkit.text_input = function(self, text)
	for tool, _ in pairs(self.visible_tools) do
		tool:text_input(text);
	end
end

return Toolkit;
