local features = require("features");
local Terminal = require("modules/cmd/terminal");

---@class Console: Tool
---@field private terminal Terminal
---@field private font love.Font
local Console = Class("Console", crystal.Tool);

if not features.cli then
	features.stub(Console);
end

Console.init = function(self, terminal)
	Console.super.init(self);
	assert(terminal);
	assert(terminal:inherits_from(Terminal));
	self.terminal = terminal;
	self.font = crystal.ui.font("crystal_console_xl");
	self.consumes_inputs = true; -- TODO remove this when there is a real UI system with text focus
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
	self.terminal:text_input(text);
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param ctrl boolean
Console.key_pressed = function(self, key, scan_code, is_repeat)
	self.terminal:key_pressed(key, scan_code, is_repeat);
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
	love.graphics.print(self.terminal:raw_input(), text_x, text_y);

	-- Draw caret
	local pre = self.terminal:input():getTextLeftOfCursor();
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
	local autocomplete = self.terminal:autocomplete_suggestions();
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
		suggestion_x = x + font:getWidth(self.terminal:parsed_input().command_untrimmed .. " ");
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
		if autocomplete.state == "command" and i == self.terminal:autocomplete_cursor() then
			love.graphics.setColor(crystal.Color.grey0);
			love.graphics.rectangle("fill", x, suggestion_y, width, font:getHeight());
			love.graphics.setColor(crystal.Color.cyan);
			love.graphics.rectangle("fill", x, suggestion_y, cursor_width, font:getHeight());
		end
		love.graphics.setColor(crystal.Color.white);
		love.graphics.print(suggestion.text, suggestion_x, suggestion_y);
	end
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

--#endregion

return function(terminal)
	assert(terminal)
	local console = Console:new(terminal);
	crystal.tool.add(console, { keybind = "`" });
end
