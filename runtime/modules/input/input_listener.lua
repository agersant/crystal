local TableUtils = require("utils/TableUtils");

---@class InputListener : Component
---@field private _player InputPlayer
---@field private handlers (fun(input: string): boolean)[]
local InputListener = Class("InputListener", crystal.Component);

InputListener.init = function(self, player_or_index)
	if type(player_or_index) == "number" then
		self._player = crystal.input.player(player_or_index);
	else
		assert(player_or_index:is_instance_of("InputPlayer"));
		self._player = player_or_index;
	end
	assert(self._player);
	self.handlers = {};
	self._disabled = 0;
end

---@return InputPlayer
InputListener.input_player = function(self)
	return self._player;
end

---@param input string
---@return boolean
InputListener.is_action_input_down = function(self, input)
	return self:input_player():is_action_active(input);
end

---@param handler fun(input: string): boolean
---@return fun()
InputListener.add_input_handler = function(self, handler)
	assert(type(handler) == "function");
	table.insert(self.handlers, handler);
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

InputListener.dispatch_inputs = function(self)
	for _, input in ipairs(self._player:events()) do
		local handlers = TableUtils.shallowCopy(self.handlers);
		for i = #handlers, 1, -1 do
			if handlers[i](input) then
				break;
			end
		end
	end
end

return InputListener;
