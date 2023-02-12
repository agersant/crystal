local features = require("features");
local Tool = require("modules/tool/tool");

---@class Toolkit
---@field private tools { [string]: Tool }
---@field private keybinds { [love.KeyConstant]: Tool }
local Toolkit = Class("Toolkit");

if not features.tools then
	features.stub(Toolkit);
end

Toolkit.init = function(self)
	self.tools = {};
	self.keybinds = {};
end

---@class ToolOptions
---@field keybind love.KeyConstant
---@field name string

---@param tool Tool
---@param options ToolOptions
Toolkit.add = function(self, tool, options)
	assert(tool:is_instance_of(Tool));
	options = options or {};

	local tool_name = options.name or tool:class_name();
	assert(not self.tools[tool_name]);
	self.tools[tool_name] = tool;

	if options.keybind then
		self.keybinds[options.keybind] = tool_name;
	end
end

---@param tool_name string
Toolkit.show = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	tool.visible = true;
	tool:show();
end

---@param tool_name string
Toolkit.hide = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	tool.visible = false;
	tool:hide();
end

---@param tool_name string
Toolkit.is_visible = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	return tool.visible;
end

---@param dt number
Toolkit.update = function(self, dt)
	for _, tool in pairs(self.tools) do
		tool:update(dt);
	end
end

Toolkit.draw = function(self)
	for _, tool in pairs(self.tools) do
		if tool.visible then
			tool:draw();
		end
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
Toolkit.key_pressed = function(self, key, scan_code, is_repeat)
	for _, tool in pairs(self.tools) do
		if tool.visible then
			tool:key_pressed(key, scan_code, is_repeat);
		end
	end

	local tool_name = self.keybinds[key];
	if tool_name then
		if self:is_visible(tool_name) then
			self:hide(tool_name);
		else
			self:show(tool_name);
		end
	end
end

---@param text string
Toolkit.text_input = function(self, text)
	for _, tool in pairs(self.tools) do
		if tool.visible then
			tool:text_input(text);
		end
	end
end

--#region Tests

crystal.test.add("Can show/hide tool", function()
	local MyTool = Class:test("MyTool", Tool);
	MyTool.show = function(self) self.visible = true; end
	MyTool.hide = function(self) self.visible = false; end

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool);

	assert(not toolkit:is_visible("MyTool"));
	assert(not tool.visible);

	toolkit:show("MyTool");
	assert(toolkit:is_visible("MyTool"));
	assert(tool.visible);

	toolkit:hide("MyTool");
	assert(not toolkit:is_visible("MyTool"));
	assert(not tool.visible);
end);

crystal.test.add("Can toggle via keybind", function()
	local MyTool = Class:test("MyTool", Tool);

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool, { keybind = "x" });

	assert(not toolkit:is_visible("MyTool"));
	assert(not tool.visible);

	toolkit:key_pressed("x", "x", false);
	assert(toolkit:is_visible("MyTool"));
	assert(tool.visible);

	toolkit:key_pressed("x", "x", false);
	assert(not toolkit:is_visible("MyTool"));
	assert(not tool.visible);
end);

crystal.test.add("Updates and draws tools", function()
	local MyTool = Class:test("MyTool", Tool);
	MyTool.update = function(self) self.updated = true; end
	MyTool.draw = function(self) self.drawn = true; end

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool);

	toolkit:update(0);
	toolkit:draw();
	assert(tool.updated);
	assert(not tool.drawn);

	toolkit:show("MyTool");
	toolkit:update(0);
	toolkit:draw();
	assert(tool.updated);
	assert(tool.drawn);
end);


crystal.test.add("Sends inputs to tools", function()
	local MyTool = Class:test("MyTool", Tool);
	MyTool.text_input = function(self) self.has_text = true; end
	MyTool.key_pressed = function(self) self.has_key = true; end

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool, { keybind = "x" });

	toolkit:key_pressed("z", "z", false);
	assert(not tool.has_key);
	toolkit:text_input("z");
	assert(not tool.has_text);

	toolkit:key_pressed("x", "x", false);
	assert(not tool.has_key);
	assert(not tool.has_text);

	toolkit:key_pressed("z", "z", false);
	assert(tool.has_key);
	toolkit:text_input("z");
	assert(tool.has_text);
end);

--#endregion

return Toolkit;
