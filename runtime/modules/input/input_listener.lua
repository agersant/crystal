---@class InputListener : Component
---@field private player InputPlayer
---@field private handlers (fun(input: string): boolean)[]
local InputListener = Class("InputListener", crystal.Component);

InputListener.init = function(self, player_or_index)
	if type(player_or_index) == "number" then
		self.player = crystal.input.player(player_or_index);
	else
		assert(player_or_index:inherits_from("InputPlayer"));
		self.player = player_or_index;
	end
	assert(self.player);
	self.handlers = {};
end

---@return InputPlayer
InputListener.input_player = function(self)
	return self.player;
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

InputListener.handle_inputs = function(self)
	for _, input in ipairs(self.player:events()) do
		local handlers = table.copy(self.handlers);
		for i = #handlers, 1, -1 do
			if handlers[i](input) then
				break;
			end
		end
	end
end

return InputListener;
