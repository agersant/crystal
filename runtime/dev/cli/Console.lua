local Features = require("dev/Features");
local Colors = require("resources/Colors");

local Console = Class("Console");

if not Features.cli then
	Features.stub(Console);
end

local fontSize = 20;
local marginX = 20;
local inputBoxPaddingX = 10;
local inputBoxPaddingY = 4;
local autoCompleteMargin = 16;
local autoCompletePaddingX = 10;
local autoCompletePaddingY = 8;
local autoCompleteCursorWidth = 2;
local autoCompleteArrowMargin = 8;
local autoCompleteArrowWidth = 16;
local autoCompleteArrowHeight = 8;

Console.init = function(self, terminal)
	assert(terminal);
	self._terminal = terminal;
	self._isActive = false;
	self._textInputWasOn = false;
	self._keyRepeatWasOn = false;
	self._font = FONTS:get("dev", fontSize);
end

Console.toggle = function(self)
	if self._isActive then
		self:disable();
	else
		self:enable();
	end
end

Console.enable = function(self)
	if self._isActive then
		return;
	end
	self._isActive = true;
	self._textInputWasOn = love.keyboard.hasTextInput();
	self._keyRepeatWasOn = love.keyboard.hasKeyRepeat();
	love.keyboard.setTextInput(true);
	love.keyboard.setKeyRepeat(true);
end

Console.disable = function(self)
	if not self._isActive then
		return;
	end
	self._isActive = false;
	love.keyboard.setTextInput(self._textInputWasOn);
	love.keyboard.setKeyRepeat(self._keyRepeatWasOn);
end

Console.isActive = function(self)
	return self._isActive;
end

Console.textInput = function(self, text)
	if not self:isActive() then
		return;
	end
	self._terminal:textInput(text);
end

Console.keyPressed = function(self, key, scanCode, ctrl)
	if scanCode == "`" then
		self:toggle();
		return;
	end
	if not self:isActive() then
		return;
	end
	self._terminal:keyPressed(key, scanCode, ctrl);
end

Console.draw = function(self)
	if not self:isActive() then
		return;
	end

	local font = self._font;
	love.graphics.setFont(font);

	-- Draw input box
	local inputBoxX = marginX;
	local inputBoxY = marginX;
	local inputBoxWidth = love.graphics.getWidth() - 2 * marginX;
	local inputBoxHeight = font:getHeight() + 2 * inputBoxPaddingY;
	local rounding = 4;
	love.graphics.setColor(Colors.greyA);
	love.graphics.rectangle("fill", inputBoxX, inputBoxY, inputBoxWidth, inputBoxHeight, rounding, rounding);

	-- Draw chevron
	local chevronX = inputBoxX + inputBoxPaddingX;
	local chevronY = inputBoxY + inputBoxPaddingY;
	local chevron = "> ";
	love.graphics.setColor(Colors.white);
	love.graphics.print(chevron, chevronX, chevronY);

	-- Draw input text
	local inputX = chevronX + font:getWidth(chevron);
	local inputY = chevronY;
	love.graphics.setColor(Colors.white);
	love.graphics.print(self._terminal:getCurrentInputText(), inputX, inputY);

	-- Draw caret
	local pre = self._terminal:getCurrentInput():getTextLeftOfCursor();
	local caretX = inputX + font:getWidth(pre);
	local caretY = inputY;
	local caretAlpha = .5 * (1 + math.sin(love.timer.getTime() * 1000 / 100));
	caretAlpha = caretAlpha * caretAlpha * caretAlpha;
	love.graphics.setColor(Colors.white:alpha(caretAlpha));
	love.graphics.rectangle("fill", caretX, caretY, 1, font:getHeight());

	-- Draw autocomplete content
	local suggestionX;
	local suggestionsWidth = 0;

	local autoComplete = self._terminal:getAutoCompleteOutput();

	for i, suggestion in ipairs(autoComplete.lines) do
		local suggestionWidth = 0;
		for j = 2, #suggestion.text, 2 do
			suggestionWidth = suggestionWidth + font:getWidth(suggestion.text[j]);
		end
		suggestionsWidth = math.max(suggestionWidth, suggestionsWidth);
	end

	if autoComplete.state == "command" then
		suggestionX = inputX;
	elseif autoComplete.state == "badcommand" then
		suggestionX = inputX;
	elseif autoComplete.state == "args" then
		suggestionX = inputX + font:getWidth(self._terminal:getParsedInput().commandUntrimmed .. " ");
	else
		error("Unexpected autocomplete state");
	end

	if #autoComplete.lines > 0 then
		-- Draw autocomplete box
		local autoCompleteBoxX = suggestionX - autoCompletePaddingX;
		local autoCompleteBoxY = inputBoxY + inputBoxHeight + autoCompleteMargin;
		local autoCompleteBoxWidth = suggestionsWidth + 2 * autoCompletePaddingX;
		local autoCompleteBoxHeight = #autoComplete.lines * font:getHeight() + 2 * autoCompletePaddingY;
		love.graphics.setColor(Colors.greyA);
		love.graphics.rectangle("fill", autoCompleteBoxX, autoCompleteBoxY, autoCompleteBoxWidth, autoCompleteBoxHeight, 2, 2);

		-- Draw autocomplete arrow
		love.graphics.polygon("fill", autoCompleteBoxX + autoCompleteArrowMargin, autoCompleteBoxY,
			autoCompleteBoxX + autoCompleteArrowMargin + autoCompleteArrowWidth, autoCompleteBoxY,
			autoCompleteBoxX + autoCompleteArrowMargin + autoCompleteArrowWidth / 2,
			autoCompleteBoxY - autoCompleteArrowHeight);

		-- Draw autocomplete content
		love.graphics.setColor(Colors.white);
		local suggestionY = autoCompleteBoxY + autoCompletePaddingY;
		for i, suggestion in ipairs(autoComplete.lines) do
			local suggestionY = suggestionY + (i - 1) * font:getHeight();
			if autoComplete.state == "command" and i == self._terminal:getAutoCompleteCursor() then
				love.graphics.setColor(Colors.grey0);
				love.graphics.rectangle("fill", autoCompleteBoxX, suggestionY, autoCompleteBoxWidth, font:getHeight());
				love.graphics.setColor(Colors.cyan);
				love.graphics.rectangle("fill", autoCompleteBoxX, suggestionY, autoCompleteCursorWidth, font:getHeight());
			end
			love.graphics.setColor(Colors.white);
			love.graphics.print(suggestion.text, suggestionX, suggestionY);
		end
	end

end

return Console;
