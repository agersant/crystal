---@class InputListener : Component
---@field private _player_index number
---@field private handlers (fun(input: string): boolean)[]
local InputListener = Class("InputListener", crystal.Component);

InputListener.init = function(self, player_index)
	assert(player_index > 0);
	self._player_index = player_index;
	self.handlers = {};
end

---@return number
InputListener.player_index = function(self)
	return self._player_index;
end

---@param handler fun(input: string): boolean
---@return fun()
InputListener.add_input_handler = function(self, handler)
	assert(type(handler) == "function");
	table.push(self.handlers, handler);
	return function()
		self:remove_input_handler(handler);
	end
end

---@param handler fun(input: string): boolean
InputListener.remove_input_handler = function(self, handler)
	for i, handler_iter in ipairs(self.handlers) do
		if handler_iter == handler then
			table.remove(self.handlers, i);
			return;
		end
	end
end

InputListener.handle_input = function(self, input)
	local handlers = table.copy(self.handlers);
	for i = #handlers, 1, -1 do
		if handlers[i](input) then
			break;
		end
	end
end

return InputListener;
