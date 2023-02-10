local UndoStack = Class("UndoStack");

UndoStack.init = function(self, maxUndo)
	self._maxUndo = maxUndo or 20;
	self:clear();
end

UndoStack.push = function(self, text, caretPosition)
	assert(type(text) == "string");
	assert(type(caretPosition) == "number");
	assert(self._stack[self._cursor]);
	if self._stack[self._cursor].text == text then
		self._stack[self._cursor].caretPosition = caretPosition;
	else
		while #self._stack > self._cursor do
			table.remove(self._stack, #self._stack);
		end
		table.insert(self._stack, { text = text, caretPosition = caretPosition });
		self._cursor = #self._stack;
		while #self._stack > self._maxUndo + 1 do
			table.remove(self._stack, 1);
			self._cursor = self._cursor - 1;
		end
	end
end

UndoStack.undo = function(self)
	self._cursor = math.max(1, self._cursor - 1);
	return self._stack[self._cursor].text, self._stack[self._cursor].caretPosition;
end

UndoStack.redo = function(self)
	self._cursor = math.min(#self._stack, self._cursor + 1);
	return self._stack[self._cursor].text, self._stack[self._cursor].caretPosition;
end

UndoStack.clear = function(self)
	self._stack = { { text = "", caretPosition = 0 } };
	self._cursor = 1;
end

UndoStack.rebase = function(self)
	self._stack = { table.remove(self._stack) };
	self._cursor = 1;
end

return UndoStack;
