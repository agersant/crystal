---@class UndoStack
---@field private max_undo number
---@field private stack { text: string, caret_position: number }[]
---@field private cursor number
local UndoStack = Class("UndoStack");

UndoStack.init = function(self, max_undo)
	self.max_undo = max_undo or 20;
	self.stack = { { text = "", caret_position = 0 } };
	self.cursor = 1;
end

---@param text string
---@param caret_position number
UndoStack.push = function(self, text, caret_position)
	assert(type(text) == "string");
	assert(type(caret_position) == "number");
	assert(self.stack[self.cursor]);
	if self.stack[self.cursor].text == text then
		self.stack[self.cursor].caret_position = caret_position;
	else
		while #self.stack > self.cursor do
			table.pop(self.stack);
		end
		table.push(self.stack, { text = text, caret_position = caret_position });
		self.cursor = #self.stack;
		while #self.stack > self.max_undo + 1 do
			table.remove(self.stack, 1);
			self.cursor = self.cursor - 1;
		end
	end
end

UndoStack.undo = function(self)
	self.cursor = math.max(1, self.cursor - 1);
	return self.stack[self.cursor].text, self.stack[self.cursor].caret_position;
end

UndoStack.redo = function(self)
	self.cursor = math.min(#self.stack, self.cursor + 1);
	return self.stack[self.cursor].text, self.stack[self.cursor].caret_position;
end

UndoStack.clear = function(self)
	self.stack = { { text = "", caret_position = 0 } };
	self.cursor = 1;
end

UndoStack.delete_history = function(self)
	self.stack = { table.pop(self.stack) };
	self.cursor = 1;
end

---@class TextInputBuffer
---@field private undo_stack UndoStack
---@field private _text string
---@field private cursor number # _text[cursor] is the letter left of the caret
local TextInputBuffer = Class("TextInputBuffer");

TextInputBuffer.init = function(self, max_undo)
	self._text = "";
	self.cursor = 0;
	self.undo_stack = UndoStack:new(max_undo);
end

TextInputBuffer.clear = function(self)
	self._text = "";
	self.cursor = 0;
	self.undo_stack:clear();
end

TextInputBuffer.delete_history = function(self)
	self.undo_stack:delete_history();
end

---@return string
TextInputBuffer.text = function(self)
	return self._text;
end

---@return string
TextInputBuffer.text_left_of_caret = function(self)
	return self._text:sub(1, self.cursor);
end

---@param text string
TextInputBuffer.set_text = function(self, text)
	assert(text);
	self._text = text;
	self:move_to_end();
	self:push_undo_state();
end

---@param text string
TextInputBuffer.text_input = function(self, text)
	assert(text);
	self:insert(text);
	self:push_undo_state();
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
---@param ctrl boolean
TextInputBuffer.key_pressed = function(self, key, scan_code, is_repeat, ctrl)
	local old_text = self._text;
	local old_cursor = self.cursor;

	if key == "home" then
		self:move_to_home();
	elseif key == "end" then
		self:move_to_end();
	elseif key == "left" then
		if ctrl then
			self:move_to_word_left();
		else
			self:move_left();
		end
	elseif key == "right" then
		if ctrl then
			self:move_to_word_right();
		else
			self:move_right();
		end
	elseif key == "backspace" then
		if self.cursor > 0 then
			local num_delete;
			if ctrl then
				num_delete = self.cursor - self:find_word_left();
			else
				num_delete = 1;
			end
			self:backspace(num_delete);
		end
	elseif key == "delete" then
		if self.cursor < #self._text then
			local num_delete;
			if ctrl then
				num_delete = self:find_word_right() - self.cursor;
			else
				num_delete = 1;
			end
			self:delete(num_delete);
		end
	elseif ctrl and key == "v" then
		local clipboard = love.system.getClipboardText();
		self:insert(clipboard);
	elseif ctrl and key == "z" then
		self:undo();
	elseif ctrl and key == "y" then
		self:redo();
	end

	local text_changed = self._text ~= old_text;
	local cursor_moved = self.cursor ~= old_cursor;

	if text_changed or cursor_moved then
		self:push_undo_state();
	end

	return text_changed, cursor_moved;
end

---@private
---@return number
TextInputBuffer.find_word_left = function(self)
	local out = self.cursor - 1;
	while out > 0 do
		local space_left = self._text:sub(out, out):find("%s");
		local space_right = self._text:sub(out + 1, out + 1):find("%s");
		if space_left and not space_right then
			break
		end
		out = out - 1;
	end
	return out;
end

---@private
---@return number
TextInputBuffer.find_word_right = function(self)
	local _, match_end = self._text:find("%s+", self.cursor + 1);
	return match_end or #self._text;
end

---@private
---@param text string
TextInputBuffer.insert = function(self, text)
	local first_non_printable = text:find("[%c]");
	if first_non_printable then
		text = text:sub(1, first_non_printable - 1);
	end
	local pre = self._text:sub(1, self.cursor);
	local post = self._text:sub(self.cursor + 1);
	self._text = pre .. text .. post;
	self.cursor = self.cursor + #text;
end

---@private
---@param num_delete number
TextInputBuffer.backspace = function(self, num_delete)
	assert(num_delete > 0);
	local pre = self._text:sub(1, self.cursor - num_delete);
	local post = self._text:sub(self.cursor + 1);
	self._text = pre .. post;
	self.cursor = self.cursor - num_delete;
	assert(self.cursor >= 0);
end

---@private
---@param num_delete number
TextInputBuffer.delete = function(self, num_delete)
	assert(num_delete > 0);
	local pre = self._text:sub(1, self.cursor);
	local post = self._text:sub(self.cursor + 1 + num_delete);
	self._text = pre .. post;
end

---@private
TextInputBuffer.move_to_home = function(self)
	self.cursor = 0;
end

---@private
TextInputBuffer.move_to_end = function(self)
	self.cursor = #self._text;
end

---@private
TextInputBuffer.move_left = function(self)
	self.cursor = math.max(0, self.cursor - 1);
end

---@private
TextInputBuffer.move_right = function(self)
	self.cursor = math.min(#self._text, self.cursor + 1);
end

---@private
TextInputBuffer.move_to_word_left = function(self)
	self.cursor = self:find_word_left();
end

---@private
TextInputBuffer.move_to_word_right = function(self)
	self.cursor = self:find_word_right();
end

---@private
TextInputBuffer.push_undo_state = function(self)
	self.undo_stack:push(self._text, self.cursor);
end

---@private
TextInputBuffer.undo = function(self)
	self._text, self.cursor = self.undo_stack:undo();
end

---@private
TextInputBuffer.redo = function(self)
	self._text, self.cursor = self.undo_stack:redo();
end

--#region Tests

crystal.test.add("Setting and clearing text", function()
	local textInput = TextInputBuffer:new();
	assert(textInput:text() == "");
	textInput:set_text("oink");
	assert(textInput:text() == "oink");
	textInput:clear();
	assert(textInput:text() == "");
end);

crystal.test.add("Letters entry", function()
	local textInput = TextInputBuffer:new();
	textInput:set_text("oink");
	textInput:text_input("g");
	textInput:text_input("r");
	textInput:text_input("u");
	textInput:text_input("i");
	textInput:text_input("k");
	assert(textInput:text() == "oinkgruik");
end);

crystal.test.add("Cursor navigation", function()
	local textInput = TextInputBuffer:new();
	textInput:set_text("oink gruik");
	textInput:key_pressed("left", nil, false, false);
	assert(textInput:text_left_of_caret() == "oink grui");
	textInput:key_pressed("left", nil, false, true);
	assert(textInput:text_left_of_caret() == "oink ");
	textInput:key_pressed("home", nil, false, false);
	assert(textInput:text_left_of_caret() == "");
	textInput:key_pressed("right", nil, false, true);
	assert(textInput:text_left_of_caret() == "oink ");
	textInput:key_pressed("right", nil, false, false);
	assert(textInput:text_left_of_caret() == "oink g");
	textInput:key_pressed("end", nil, false, false);
	assert(textInput:text_left_of_caret() == "oink gruik");
end);

crystal.test.add("Undo and redo", function()
	local textInput = TextInputBuffer:new();
	textInput:set_text("oink");
	textInput:text_input("g");
	textInput:text_input("r");
	textInput:text_input("u");
	textInput:text_input("i");
	textInput:text_input("k");
	assert(textInput:text() == "oinkgruik");

	textInput:key_pressed("z", nil, false, true);
	textInput:key_pressed("z", nil, false, true);
	assert(textInput:text() == "oinkgru");

	textInput:key_pressed("y", nil, false, true);
	textInput:key_pressed("y", nil, false, true);
	assert(textInput:text() == "oinkgruik");

	textInput:set_text("oink");
	textInput:set_text("gruik");
	textInput:key_pressed("y", nil, false, true);
	assert(textInput:text() == "gruik");
	textInput:key_pressed("z", nil, false, true);
	assert(textInput:text() == "oink");
end);

crystal.test.add("Backspace", function()
	local textInput = TextInputBuffer:new();
	textInput:set_text("gruik oink");
	textInput:key_pressed("backspace", nil, false, false);
	assert(textInput:text() == "gruik oin");
	textInput:key_pressed("backspace", nil, false, true);
	assert(textInput:text() == "gruik ");
end);

crystal.test.add("Delete", function()
	local textInput = TextInputBuffer:new();
	textInput:set_text("gruik oink");
	textInput:key_pressed("home", nil, false, false);
	textInput:key_pressed("delete", nil, false, false);
	assert(textInput:text() == "ruik oink");
	textInput:key_pressed("delete", nil, false, true);
	assert(textInput:text() == "oink");
end);

--#endregion

return TextInputBuffer;
