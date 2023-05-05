---@alias InputRelevance "always" | "when_focused"

---@class Router
---@field private handlers { [string]: { [UIElement]: InputRelevance } }
---@field private focused_elements { [number]: { [UIElement]: boolean } }
---@field private _mouse_inside_elements { [UIElement]: boolean }
---@field private _mouse_over_elements { [UIElement]: boolean }
local Router = Class("Router");

Router.init = function(self)
	self.handlers = {};
	self.focused_elements = {};
	self._mouse_inside_elements = setmetatable({}, { __mode = "k" });
	self._mouse_over_elements = setmetatable({}, { __mode = "k" });
end

Router.reset = function(self)
	self.handlers = {};
	self.focused_elements = {};
	table.clear(self._mouse_inside_elements);
	table.clear(self._mouse_over_elements);
end

---@param context UIElement
---@param player_index number
---@param input string
---@return boolean
Router.route_input = function(self, context, player_index, input)
	assert(context);
	assert(type(player_index) == "number");
	assert(type(input) == "string");

	local handlers = self.handlers[input] or {};

	-- Run callbacks on focus path
	local focused_elements = self.focused_elements[player_index] or {};
	for focused_element in pairs(focused_elements) do
		if self:can_element_receive_input(context, focused_element, player_index, input) then
			local recipient = focused_element;
			while recipient do
				if handlers[recipient] == "when_focused" then
					local binding = recipient:binding(input);
					assert(binding);
					local callback = binding.callback;
					assert(type(callback) == "function");
					if callback(player_index, input) then
						return true;
					end
				end
				recipient = recipient:parent();
			end
		end
	end

	-- Run callbacks not tied to focus
	for recipient, relevance in pairs(handlers) do
		if relevance == "always" then
			if self:can_element_receive_input(context, recipient, player_index) then
				local binding = recipient:binding(input);
				assert(binding);
				local callback = binding.callback;
				assert(type(callback) == "function");
				if callback(player_index, input) then
					return true;
				end
			end
		end
	end

	if input == "ui_down" then
		return self:move_focus(context, player_index, "down");
	elseif input == "ui_up" then
		return self:move_focus(context, player_index, "up");
	elseif input == "ui_right" then
		return self:move_focus(context, player_index, "right");
	elseif input == "ui_left" then
		return self:move_focus(context, player_index, "left");
	end

	return false;
end

---@param context UIElement
---@param element UIElement
---@param player_index number
---@param input string
---@return boolean
Router.can_element_receive_input = function(self, context, element, player_index)
	assert(context);
	assert(element);
	assert(type(player_index) == "number");

	local is_within_context = false;
	while element do
		if element == context then
			is_within_context = true;
		end
		local player_filter = element:player_index();
		if player_filter and player_filter ~= player_index then
			return false;
		end
		if not element:is_active() then
			return false;
		end
		element = element:parent();
	end

	return is_within_context;
end

--#region Bindings

Router.bind_input = function(self, element, input, relevance)
	assert(element);
	assert(type(input) == "string");
	assert(relevance == "always" or relevance == "when_focused");
	assert(element:binding(input));
	if not self.handlers[input] then
		self.handlers[input] = setmetatable({}, { __mode = "k" });
	end
	self.handlers[input][element] = relevance;
end

Router.unbind_input = function(self, element, input)
	assert(element);
	assert(type(input) == "string");
	assert(not element:binding(input));
	if self.handlers[input] then
		self.handlers[input][element] = nil;
	end
end

---@param context UIElement
---@param player_index number
---@return { [string]: { owner: UIElement, relevance: InputRelevance, binding: Binding }[] }
Router.active_bindings_in = function(self, context, player_index)
	local active_bindings = {}
	for input, handlers in pairs(self.handlers) do
		for recipient, relevance in pairs(handlers) do
			if relevance == "always" or self:is_on_focus_path(recipient, player_index) then
				if self:can_element_receive_input(context, recipient, player_index, input) then
					active_bindings[input] = active_bindings[input] or {};
					table.push(active_bindings[input], {
						owner = recipient,
						relevance = relevance,
						binding = recipient:binding(input),
					});
				end
			end
		end
	end
	return active_bindings;
end

--#endregion

--#region Mouse

---@return { [UIElement]: boolean }
Router.mouse_inside_elements = function(self)
	return table.copy(self._mouse_inside_elements);
end

---@param element UIElement
Router.add_mouse_inside_element = function(self, element)
	self._mouse_inside_elements[element] = true;
end

---@param element UIElement
Router.remove_mouse_inside_element = function(self, element)
	self._mouse_inside_elements[element] = nil;
end

---@param element UIElement
---@return boolean
Router.is_mouse_inside_element = function(self, element)
	return self._mouse_inside_elements[element] ~= nil;
end

---@return { [UIElement]: boolean }
Router.mouse_over_elements = function(self)
	return table.copy(self._mouse_over_elements);
end

---@param element UIElement
Router.add_mouse_over_element = function(self, element)
	self._mouse_over_elements[element] = true;
end

---@param element UIElement
Router.remove_mouse_over_element = function(self, element)
	self._mouse_over_elements[element] = nil;
end

---@param element UIElement
---@return boolean
Router.is_mouse_over_element = function(self, element)
	return self._mouse_over_elements[element] ~= nil;
end

--#endregion

--#region Focus

---@private
---@param context UIElement
---@param player_index number
---@param direction Direction
---@return boolean
Router.move_focus = function(self, context, player_index, direction)
	local from_element = self:input_recipient_in(context, player_index);
	if not from_element then
		return false;
	end
	local to_element = from_element:next_focusable(from_element, player_index, direction);
	if to_element and to_element ~= from_element then
		self:transfer_focus(context, to_element, player_index);
		return true;
	end
	return false;
end

---@param context UIElement
---@param player_index number
---@param direction Direction
---@return boolean
Router.transfer_focus = function(self, context, new_focus, player_index)
	assert(context);
	assert(new_focus);
	assert(type(player_index) == "number");
	assert(self:can_element_receive_input(context, new_focus, player_index));
	local old_focus = self:input_recipient_in(context, player_index);
	if old_focus then
		self:unfocus_element(old_focus, player_index);
	end
	self:focus_element(new_focus, player_index);
end

---@private
---@param context UIElement
---@param player_index number
---@return UIElement
Router.input_recipient_in = function(self, context, player_index)
	assert(context);
	assert(type(player_index) == "number");
	local focused_elements = self.focused_elements[player_index];
	if focused_elements then
		for focused_element in pairs(focused_elements) do
			if self:can_element_receive_input(context, focused_element, player_index) then
				return focused_element;
			end
		end
	end
	return nil;
end

---@private
---@param element UIElement
---@param player_index number
Router.focus_element = function(self, element, player_index)
	assert(element);
	assert(type(player_index) == "number");
	assert(self:can_element_receive_input(element:root(), element, player_index));
	if not self.focused_elements[player_index] then
		self.focused_elements[player_index] = setmetatable({}, { __mode = "k" });
	end
	if not self.focused_elements[player_index][element] then
		self.focused_elements[player_index][element] = true;
		element:on_focus();
	end
end

---@private
---@param element UIElement
---@param player_index number
Router.unfocus_element = function(self, element, player_index)
	assert(element);
	assert(type(player_index) == "number");
	if self.focused_elements[player_index] then
		if self.focused_elements[player_index][element] then
			self.focused_elements[player_index][element] = nil;
			element:on_unfocus();
		end
	end
end

---@param player_index number
---@param element UIElement
Router.is_element_focused = function(self, element, player_index)
	assert(element);
	assert(type(player_index) == "number");
	return self.focused_elements[player_index] and self.focused_elements[player_index][element] ~= nil;
end

---@param context UIElement
---@param player_index number
Router.unfocus_all_elements_in = function(self, context, player_index)
	assert(context);
	assert(type(player_index) == "number");
	if not self.focused_elements[player_index] then
		return;
	end
	local all_focused = table.copy(self.focused_elements[player_index]);
	for focused in pairs(all_focused) do
		if focused:is_within(context) then
			self:unfocus_element(focused, player_index);
		end
	end
end

---@private
---@param element UIElement
---@param player_index number
---@return boolean
Router.is_on_focus_path = function(self, element, player_index)
	assert(element);
	assert(type(player_index) == "number");
	if not self.focused_elements[player_index] then
		return false;
	end
	for focused_element in pairs(self.focused_elements[player_index]) do
		if focused_element:is_within(element) then
			return true;
		end
	end
	return false;
end

--#endregion

return Router;
