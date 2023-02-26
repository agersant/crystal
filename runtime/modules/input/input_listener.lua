local TableUtils = require("utils/TableUtils");

---@class InputListener : Component
---@field private _device InputDevice
---@field private handlers (fun(input: string): boolean)[]
local InputListener = Class("InputListener", crystal.Component);

InputListener.init = function(self, device_or_device_index)
	if type(device_or_device_index) == "number" then
		self._device = crystal.input.device(device_or_device_index);
	else
		assert(device_or_device_index:is_instance_of("InputDevice"));
		self._device = device_or_device_index;
	end
	assert(self._device);
	self.handlers = {};
	self._disabled = 0;
end

---@return InputDevice
InputListener.input_device = function(self)
	return self._device;
end

---@param input string
---@return boolean
InputListener.is_input_down = function(self, input)
	return self:input_device():is_action_active(input);
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
	for _, input in ipairs(self._device:events()) do
		local handlers = TableUtils.shallowCopy(self.handlers);
		for i = #handlers, 1, -1 do
			if handlers[i](input) then
				break;
			end
		end
	end
end

return InputListener;
