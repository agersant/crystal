local UndoStack = require("ui/UndoStack");

local TextInput = Class("TextInput");

local findLeftWord = function(self)
	local out = self._cursor - 1;
	while out > 0 do
		local spaceLeft = self._text:sub(out, out):find("%s");
		local spaceRight = self._text:sub(out + 1, out + 1):find("%s");
		if spaceLeft and not spaceRight then
			break
		end
		out = out - 1;
	end
	return out;
end

local findRightWord = function(self)
	local matchStart, matchEnd = self._text:find("%s+", self._cursor + 1);
	return matchEnd or #self._text;
end

local insert = function(self, text)
	local firstNonPrintable = text:find("[%c]");
	if firstNonPrintable then
		text = text:sub(1, firstNonPrintable - 1);
	end
	local pre = self._text:sub(1, self._cursor);
	local post = self._text:sub(self._cursor + 1);
	self._text = pre .. text .. post;
	self._cursor = self._cursor + #text;
end

local backspace = function(self, numDelete)
	assert(numDelete > 0);
	local pre = self._text:sub(1, self._cursor - numDelete);
	local post = self._text:sub(self._cursor + 1);
	self._text = pre .. post;
	self._cursor = self._cursor - numDelete;
	assert(self._cursor >= 0);
end

local delete = function(self, numDelete)
	assert(numDelete > 0);
	local pre = self._text:sub(1, self._cursor);
	local post = self._text:sub(self._cursor + 1 + numDelete);
	self._text = pre .. post;
end

local moveToHome = function(self)
	self._cursor = 0;
end

local moveToEnd = function(self)
	self._cursor = #self._text;
end

local moveLeft = function(self)
	self._cursor = math.max(0, self._cursor - 1);
end

local moveRight = function(self)
	self._cursor = math.min(#self._text, self._cursor + 1);
end

local moveToWordLeft = function(self)
	self._cursor = findLeftWord(self);
end

local moveToWordRight = function(self)
	self._cursor = findRightWord(self);
end

local pushUndoState = function(self)
	self._undoStack:push(self._text, self._cursor);
end

local undo = function(self)
	self._text, self._cursor = self._undoStack:undo();
end

local redo = function(self)
	self._text, self._cursor = self._undoStack:redo();
end

TextInput.init = function(self, maxUndo)
	self._undoStack = UndoStack:new(maxUndo);
	self:clear();
end

TextInput.clear = function(self)
	self._text = "";
	self._cursor = 0; -- _text[_cursor] is the letter left of the caret
	self._undoStack:clear();
end

TextInput.rebaseUndoStack = function(self)
	self._undoStack:rebase();
end

TextInput.getText = function(self)
	return self._text;
end

TextInput.getTextLeftOfCursor = function(self)
	return self._text:sub(1, self._cursor);
end

TextInput.setText = function(self, text)
	assert(text);
	self._text = text;
	moveToEnd(self);
	pushUndoState(self);
end

TextInput.getCursor = function(self)
	return self._cursor;
end

TextInput.textInput = function(self, text)
	assert(text);
	insert(self, text);
	pushUndoState(self);
end

TextInput.keyPressed = function(self, key, scanCode, ctrl)
	local oldText = self._text;
	local oldCursor = self._cursor;

	if key == "home" then
		moveToHome(self);
	elseif key == "end" then
		moveToEnd(self);
	elseif key == "left" then
		if ctrl then
			moveToWordLeft(self);
		else
			moveLeft(self);
		end
	elseif key == "right" then
		if ctrl then
			moveToWordRight(self);
		else
			moveRight(self);
		end
	elseif key == "backspace" then
		if self._cursor > 0 then
			local numDelete;
			if ctrl then
				numDelete = self._cursor - findLeftWord(self);
			else
				numDelete = 1;
			end
			backspace(self, numDelete);
		end
	elseif key == "delete" then
		if self._cursor < #self._text then
			local numDelete;
			if ctrl then
				numDelete = findRightWord(self) - self._cursor;
			else
				numDelete = 1;
			end
			delete(self, numDelete);
		end
	elseif ctrl and key == "v" then
		local clipboard = love.system.getClipboardText();
		insert(self, clipboard);
	elseif ctrl and key == "z" then
		undo(self);
	elseif ctrl and key == "y" then
		redo(self);
	end

	local textChanged = self._text ~= oldText;
	local cursorMoved = self._cursor ~= oldCursor;

	if textChanged or cursorMoved then
		pushUndoState(self);
	end

	return textChanged, cursorMoved;
end

--#region Tests

crystal.test.add("Setting and clearing text", function()
	local textInput = TextInput:new();
	assert(textInput:getText() == "");
	textInput:setText("oink");
	assert(textInput:getText() == "oink");
	textInput:clear();
	assert(textInput:getText() == "");
end);

crystal.test.add("Letters entry", function()
	local textInput = TextInput:new();
	textInput:setText("oink");
	textInput:textInput("g");
	textInput:textInput("r");
	textInput:textInput("u");
	textInput:textInput("i");
	textInput:textInput("k");
	assert(textInput:getText() == "oinkgruik");
end);

crystal.test.add("Cursor navigation", function()
	local textInput = TextInput:new();
	textInput:setText("oink gruik");
	textInput:keyPressed("left", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink grui");
	textInput:keyPressed("left", nil, true);
	assert(textInput:getTextLeftOfCursor() == "oink ");
	textInput:keyPressed("home", nil, false);
	assert(textInput:getTextLeftOfCursor() == "");
	textInput:keyPressed("right", nil, true);
	assert(textInput:getTextLeftOfCursor() == "oink ");
	textInput:keyPressed("right", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink g");
	textInput:keyPressed("end", nil, false);
	assert(textInput:getTextLeftOfCursor() == "oink gruik");
end);

crystal.test.add("Undo and redo", function()
	local textInput = TextInput:new();
	textInput:setText("oink");
	textInput:textInput("g");
	textInput:textInput("r");
	textInput:textInput("u");
	textInput:textInput("i");
	textInput:textInput("k");
	assert(textInput:getText() == "oinkgruik");

	textInput:keyPressed("z", nil, true);
	textInput:keyPressed("z", nil, true);
	assert(textInput:getText() == "oinkgru");

	textInput:keyPressed("y", nil, true);
	textInput:keyPressed("y", nil, true);
	assert(textInput:getText() == "oinkgruik");

	textInput:setText("oink");
	textInput:setText("gruik");
	textInput:keyPressed("y", nil, true);
	assert(textInput:getText() == "gruik");
	textInput:keyPressed("z", nil, true);
	assert(textInput:getText() == "oink");
end);

crystal.test.add("Backspace", function()
	local textInput = TextInput:new();
	textInput:setText("gruik oink");
	textInput:keyPressed("backspace", nil, false);
	assert(textInput:getText() == "gruik oin");
	textInput:keyPressed("backspace", nil, true);
	assert(textInput:getText() == "gruik ");
end);

crystal.test.add("Delete", function()
	local textInput = TextInput:new();
	textInput:setText("gruik oink");
	textInput:keyPressed("home", nil, false);
	textInput:keyPressed("delete", nil, false);
	assert(textInput:getText() == "ruik oink");
	textInput:keyPressed("delete", nil, true);
	assert(textInput:getText() == "oink");
end);

--#endregion

return TextInput;
