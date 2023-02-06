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

return TextInput;
