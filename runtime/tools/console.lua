local features = require(CRYSTAL_RUNTIME .. "/features");
local Terminal = require(CRYSTAL_RUNTIME .. "/modules/cmd/terminal");
local TextInputBuffer = require(CRYSTAL_RUNTIME .. "/modules/ui/text_input_buffer");
local Autocomplete = require(CRYSTAL_RUNTIME .. "/tools/console/autocomplete");

---@class HistoryEntry
---@field input TextInputBuffer
---@field submitted string

---@class Console: Tool
---@field private font love.Font
---@field private terminal Terminal
---@field private unguided_input string
---@field private parsed_input ParsedInput
---@field private autocomplete Autocomplete
---@field private autocomplete_cursor integer
---@field private history HistoryEntry[]
---@field private history_index integer
local Console = Class("Console", crystal.Tool);

if not features.cli then
	features.stub(Console);
end

Console.init = function(self, terminal)
	assert(terminal);
	Console.super.init(self);
	self.consumes_inputs = true; -- TODO remove this when there is a real UI system with text focus
	self.font = crystal.ui.font("crystal_regular_xl");
	self.terminal = terminal;
	self.unguided_input = "";
	self.parsed_input = nil;
	self.autocomplete = Autocomplete:new(terminal:command_store(), terminal:type_store());
	self.autocomplete_cursor = 0;

	local undo_stack_size = 20;
	self.history = { { input = TextInputBuffer:new(undo_stack_size) } };
	self.history_index = 1;
	self.parsed_input = self.terminal:parse(self:raw_input());
end

Console.show = function(self)
	love.keyboard.setTextInput(true); -- TODO this should happen when focusing text inputs in general
	love.keyboard.setKeyRepeat(true); -- TODO this should happen when focusing text inputs in general
end

Console.hide = function(self)
	love.keyboard.setTextInput(false);
	love.keyboard.setKeyRepeat(false);
end

---@param text string
Console.text_input = function(self, text)
	self:input_buffer():text_input(text);
	self.unguided_input = self:raw_input();
	self:on_input_changed();
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param ctrl boolean
Console.key_pressed = function(self, key, scan_code, is_repeat)
	if key == "return" or key == "kpenter" then
		self:submit_input();
		return;
	end

	if key == "up" then
		self:navigate_history_backward();
	end

	if key == "down" then
		self:navigate_history_forward();
	end

	local suggestions = self.autocomplete:suggestions();
	if key == "tab" and suggestions.state == "command" then
		local num_suggestions = #suggestions.lines;
		if num_suggestions > 0 then
			if self.autocomplete_cursor == 0 then
				self.autocomplete_cursor = 1;
			else
				self.autocomplete_cursor = (self.autocomplete_cursor + 1) % (num_suggestions + 1);
			end
			if self.autocomplete_cursor == 0 then
				self:input_buffer():set_text(self.unguided_input);
			else
				self:input_buffer():set_text(suggestions.lines[self.autocomplete_cursor].command:name());
			end
		end
		return;
	end

	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl");
	local text_changed, _ = self:input_buffer():key_pressed(key, scan_code, is_repeat, ctrl);
	self.unguided_input = self:raw_input();
	if text_changed then
		self:on_input_changed();
	end
end

---@private
Console.on_input_changed = function(self)
	self.autocomplete_cursor = 0;
	self.parsed_input = self.terminal:parse(self:raw_input());
	self.autocomplete:set_input(self.parsed_input);
end

---@private
Console.navigate_history_backward = function(self)
	self.history_index = math.min(self.history_index + 1, #self.history);
	self:on_input_changed();
end

---@private
Console.navigate_history_forward = function(self)
	self.history_index = math.max(self.history_index - 1, 1);
	self:on_input_changed();
end

---@private
---@param command string
Console.push_to_history = function(self, command)
	local history_size = 100;
	self.history[1].submitted = command;
	if #self.history > history_size then
		table.pop(self.history);
	end
	for _, entry in ipairs(self.history) do
		entry.input:set_text(entry.submitted);
		entry.input:delete_history();
	end
end

---@private
Console.submit_input = function(self)
	local command = self:raw_input():trim();
	if #command == 0 then
		return;
	end
	self:push_to_history(command);
	table.insert(self.history, 1, { input = TextInputBuffer:new(undo_stack_size) });
	self.history_index = 1;
	self:on_input_changed();
	crystal.tool.hide("Console");
	self.terminal:run(command);
end

---@private
---@return TextInputBuffer
Console.input_buffer = function(self)
	return self.history[self.history_index].input;
end

---@private
---@return string
Console.raw_input = function(self)
	return self:input_buffer():text();
end

Console.draw = function(self)
	local font = self.font;
	love.graphics.setFont(font);

	local margin_x = 20;
	local padding_x = 10;
	local padding_y = 4;

	-- Draw input box
	local input_box_x = margin_x;
	local input_box_y = margin_x;
	local width = love.graphics.getWidth() - 2 * margin_x;
	local height = font:getHeight() + 2 * padding_y;
	local rounding = 4;
	love.graphics.setColor(crystal.Color.greyA);
	love.graphics.rectangle("fill", input_box_x, input_box_y, width, height, rounding, rounding);

	-- Draw chevron
	local chevron_x = input_box_x + padding_x;
	local chevron_y = input_box_y + padding_y;
	local chevron = "> ";
	love.graphics.setColor(crystal.Color.white);
	love.graphics.print(chevron, chevron_x, chevron_y);

	-- Draw input text
	local text_x = chevron_x + font:getWidth(chevron);
	local text_y = chevron_y;
	love.graphics.setColor(crystal.Color.white);
	love.graphics.print(self:raw_input(), text_x, text_y);

	-- Draw caret
	local pre = self:input_buffer():text_left_of_caret();
	local caret_x = text_x + font:getWidth(pre);
	local caret_y = text_y;
	local caret_alpha = .5 * (1 + math.sin(love.timer.getTime() * 1000 / 100));
	caret_alpha = caret_alpha * caret_alpha * caret_alpha;
	love.graphics.setColor(crystal.Color.white:alpha(caret_alpha));
	love.graphics.rectangle("fill", caret_x, caret_y, 1, font:getHeight());

	-- Draw autocomplete
	self:draw_autocomplete(text_x, input_box_y + height);
end

---@private
---@param x number
---@param y number
Console.draw_autocomplete = function(self, x, y)
	local font = self.font;
	local autocomplete = self.autocomplete:suggestions();
	if #autocomplete.lines == 0 then
		return;
	end

	local suggestions_width = 0;
	for i, suggestion in ipairs(autocomplete.lines) do
		local suggestion_width = 0;
		for j = 2, #suggestion.text, 2 do
			suggestion_width = suggestion_width + font:getWidth(suggestion.text[j]);
		end
		suggestions_width = math.max(suggestion_width, suggestions_width);
	end

	local suggestion_x;
	if autocomplete.state == "command" then
		suggestion_x = x;
	elseif autocomplete.state == "badcommand" then
		suggestion_x = x;
	elseif autocomplete.state == "args" then
		suggestion_x = x + font:getWidth(self.parsed_input.command_untrimmed .. " ");
	else
		error("Unexpected autocomplete state");
	end

	local margin = 16;
	local padding_x = 10;
	local padding_y = 8;
	local cursor_width = 2;
	local arrow_margin = 8;
	local arrow_width = 16;
	local arrow_height = 8;

	-- Draw box
	local x = suggestion_x - padding_x;
	local y = y + margin;
	local width = suggestions_width + 2 * padding_x;
	local height = #autocomplete.lines * font:getHeight() + 2 * padding_y;
	love.graphics.setColor(crystal.Color.greyA);
	love.graphics.rectangle("fill", x, y, width, height, 2, 2);

	-- Draw arrow
	love.graphics.polygon("fill",
		x + arrow_margin, y,
		x + arrow_margin + arrow_width, y,
		x + arrow_margin + arrow_width / 2, y - arrow_height
	);

	-- Draw content
	love.graphics.setColor(crystal.Color.white);
	local suggestion_y = y + padding_y;
	for i, suggestion in ipairs(autocomplete.lines) do
		local suggestion_y = suggestion_y + (i - 1) * font:getHeight();
		if autocomplete.state == "command" and i == self.autocomplete_cursor then
			love.graphics.setColor(crystal.Color.grey0);
			love.graphics.rectangle("fill", x, suggestion_y, width, font:getHeight());
			love.graphics.setColor(crystal.Color.cyan);
			love.graphics.rectangle("fill", x, suggestion_y, cursor_width, font:getHeight());
		end
		love.graphics.setColor(crystal.Color.white);
		love.graphics.print(suggestion.text, suggestion_x, suggestion_y);
	end
end

Console.save = function(self)
	return { history = self.history };
end

Console.load = function(self, savestate)
	assert(savestate.history);
	self.history = savestate.history;
end

--#region Tests

crystal.test.add("Can draw console", function()
	local terminal = Terminal:new();
	terminal:add_command("example arg1:string arg2:number", function()
	end);

	local console = Console:new(terminal);
	console:draw();

	local input = "example foo bar";
	for i = 1, #input do
		local char = input:sub(i, i)
		console:text_input(char);
		console:draw();
	end
end);

crystal.test.add("Can navigate console history", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);

	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);

	console:text_input("testCommand 1");
	console:key_pressed("return");
	console:text_input("testCommand 2");
	console:key_pressed("return");
	console:text_input("testCommand 3");
	console:key_pressed("return");
	assert(sentinel == "3");

	console:key_pressed("up");
	console:key_pressed("up");
	console:key_pressed("up");
	console:key_pressed("down");
	console:key_pressed("return");
	assert(sentinel == "2");
end);

crystal.test.add("Console history size is capped", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);

	local sentinel = "";
	terminal:add_command("testCommand value:string", function(value)
		sentinel = value;
	end);

	for i = 1, 150 do
		console:text_input("testCommand " .. i);
		console:key_pressed("return");
	end

	for i = 1, 200 do
		console:key_pressed("up");
	end
	console:key_pressed("return");
end);

crystal.test.add("Console performs autocomplete when pressing Tab", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);

	local sentinel = "";
	terminal:add_command("testCommand", function()
		sentinel = "oink";
	end);
	console:text_input("testcomm");
	console:key_pressed("tab");
	console:key_pressed("return");
	assert(sentinel == "oink");
end);

crystal.test.add("Console can navigate autocomplete suggestions", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);

	local sentinel;
	for i = 1, 3 do
		terminal:add_command("testCommand" .. i, function()
			sentinel = i;
		end);
	end
	console:text_input("test");
	console:key_pressed("tab");
	console:key_pressed("tab");
	console:key_pressed("tab");
	console:key_pressed("return");
	assert(sentinel == 3);
end);

crystal.test.add("Console autocomplete updates after non-text input", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);

	local sentinel;
	terminal:add_command("testCommand", function()
		sentinel = true;
	end);
	console:text_input("testB");
	console:key_pressed("backspace");
	console:key_pressed("tab");
	console:key_pressed("return");
	assert(sentinel);
end);

crystal.test.add("Console swallows incorrect commands", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);
	console:text_input("badcommand");
	console:key_pressed("return");
end);

crystal.test.add("Console swallows command errors", function()
	local terminal = Terminal:new();
	local console = Console:new(terminal);
	terminal:add_command("testCommand", function()
		error("bonk");
	end);
	console:text_input("testCommand");
	console:key_pressed("return");
end);

--#endregion

-- TODO.hot_reload Console history should be preserved

return function(terminal)
	assert(terminal);
	local console = Console:new(terminal);
	crystal.tool.add(console, { keybind = "`" });
end
