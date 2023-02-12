local features = require("features");
local Tool = require("modules/tool/tool");

---@class Toolkit
---@field private tools Tool[]
---@field private keybinds { [love.KeyConstant]: Tool }
---@field private visible_tools { [Tool]: boolean }
local Toolkit = Class("Toolkit");

if not features.tools then
	features.stub(Toolkit);
end

Toolkit.init = function(self)
	self.tools = {};
	self.keybinds = {};
	self.visible_tools = {};
end

---@class ToolOptions
---@field keybind love.KeyConstant

---@param tool Tool
---@param options ToolOptions
Toolkit.add = function(self, tool, options)
	assert(tool:is_instance_of(Tool));
	self.tools[tool:class_name()] = tool;
	if options then
		if options.keybind then
			self.keybinds[options.keybind] = tool;
		end
	end
end

---@param tool_name string
Toolkit.show = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool] = true;
end

---@param tool_name string
Toolkit.hide = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool] = nil;
end

---@param tool_name string
Toolkit.is_visible = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	return self.visible_tools[tool];
end

---@param dt number
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

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
Toolkit.key_pressed = function(self, key, scan_code, is_repeat)
	for tool, _ in pairs(self.visible_tools) do
		tool:key_pressed(key, scan_code, is_repeat);
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

---@param text string
Toolkit.text_input = function(self, text)
	for tool, _ in pairs(self.visible_tools) do
		tool:text_input(text);
	end
end

return Toolkit;
