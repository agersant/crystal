local features = require(CRYSTAL_RUNTIME .. "/features");
local Tool = require(CRYSTAL_RUNTIME .. "/modules/tool/tool");

---@class Toolkit
---@field private tools { [string]: Tool }
---@field private visible_tools { [string]: boolean }
---@field private keybinds { [love.KeyConstant]: Tool }
local Toolkit = Class("Toolkit");

if not features.tools then
	features.stub(Toolkit);
end

Toolkit.init = function(self)
	self.tools = {};
	self.visible_tools = {};
	self.keybinds = {};
end

---@class ToolOptions
---@field keybind love.KeyConstant
---@field name string
---@field show_command string
---@field hide_command string

---@param tool Tool
---@param options ToolOptions
Toolkit.add = function(self, tool, options)
	assert(tool:inherits_from(Tool));
	options = options or {};

	local tool_name = options.name or tool:class_name();
	assert(not self.tools[tool_name]);
	self.tools[tool_name] = tool;

	if options.keybind then
		self.keybinds[options.keybind] = tool_name;
	end

	if options.show_command then
		crystal.cmd.add(options.show_command, function()
			self:show(tool_name);
		end);
	end

	if options.hide_command then
		crystal.cmd.add(options.hide_command, function()
			self:hide(tool_name);
		end);
	end
end

---@param tool_name string
Toolkit.show = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool_name] = true;
	tool.is_visible = function() return true end;
	tool:show();
end

---@param tool_name string
Toolkit.hide = function(self, tool_name)
	assert(type(tool_name) == "string");
	local tool = self.tools[tool_name];
	assert(tool);
	self.visible_tools[tool_name] = nil;
	tool.is_visible = function() return false end;
	tool:hide();
end

---@param tool_name string
Toolkit.is_visible = function(self, tool_name)
	assert(type(tool_name) == "string");
	return self.visible_tools[tool_name];
end

---@param dt number
Toolkit.update = function(self, dt)
	for _, tool in pairs(self.tools) do
		tool:update(dt);
	end
end

Toolkit.draw = function(self)
	for tool_name, tool in pairs(self.tools) do
		if self.visible_tools[tool_name] then
			tool:draw();
		end
	end
end

-- TODO remove this when there is a real UI system with text focus
---@return boolean
Toolkit.consumes_inputs = function(self)
	for tool_name, tool in pairs(self.tools) do
		if self.visible_tools[tool_name] and tool.consumes_inputs then
			return true;
		end
	end
	return false;
end

---@return { visible_tools: { [string]: bool }, [string]: any }
Toolkit.save = function(self)
	local savestate = {};
	for tool_name, tool in pairs(self.tools) do
		savestate[tool_name] = tool:save();
	end
	savestate.visible_tools = table.copy(self.visible_tools);
	return savestate;
end

---@param savestate { visible_tools: { [string]: bool }, [string]: any }
Toolkit.load = function(self, savestate)
	assert(savestate);
	for tool_name, tool_state in pairs(savestate) do
		local tool = self.tools[tool_name];
		if tool then
			if savestate.visible_tools[tool_name] then
				self:show(tool_name);
			end
			tool:load(tool_state);
		end
	end
end

Toolkit.quit = function(self)
	for _, tool in pairs(self.tools) do
		tool:quit();
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
Toolkit.key_pressed = function(self, key, scan_code, is_repeat)
	for tool_name, tool in pairs(self.tools) do
		if self.visible_tools[tool_name] then
			tool:key_pressed(key, scan_code, is_repeat);
		end
	end

	local tool_name = self.keybinds[key];
	if tool_name then
		if self.visible_tools[tool_name] then
			self:hide(tool_name);
		else
			self:show(tool_name);
		end
	end
end

---@param text string
Toolkit.text_input = function(self, text)
	for tool_name, tool in pairs(self.tools) do
		if self.visible_tools[tool_name] then
			tool:text_input(text);
		end
	end
end

--#region Tests

crystal.test.add("Can show/hide tool", function()
	local MyTool = Class:test("MyTool", Tool);
	local v;
	MyTool.show = function(self) v = true; end
	MyTool.hide = function(self) v = false; end

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool);

	assert(not toolkit:is_visible("MyTool"));
	assert(not tool:is_visible());
	assert(not v);

	toolkit:show("MyTool");
	assert(toolkit:is_visible("MyTool"));
	assert(tool:is_visible());
	assert(v);

	toolkit:hide("MyTool");
	assert(not toolkit:is_visible("MyTool"));
	assert(not tool:is_visible());
	assert(not v);
end);

crystal.test.add("Can toggle via keybind", function()
	local MyTool = Class:test("MyTool", Tool);

	local toolkit = Toolkit:new();
	local tool = MyTool:new();
	toolkit:add(tool, { keybind = "x" });

	assert(not toolkit:is_visible("MyTool"));
	assert(not tool:is_visible());

	toolkit:key_pressed("x", "x", false);
	assert(toolkit:is_visible("MyTool"));
	assert(tool:is_visible());

	toolkit:key_pressed("x", "x", false);
	assert(not toolkit:is_visible("MyTool"));
	assert(not tool:is_visible());
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
