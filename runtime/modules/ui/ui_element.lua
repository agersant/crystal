---@alias Binding { details: any, callback: fun(self: UIElement, player_index: number): boolean }

---@class UIElement
---@field private _joint Joint
---@field private desired_width number
---@field private desired_height number
---@field private left number
---@field private right number
---@field private top number
---@field private bottom number
---@field private _color Color
---@field private _opacity number
---@field private translation_x number
---@field private translation_y number
---@field private pivot_x number
---@field private pivot_y number
---@field private scale_x number
---@field private scale_y number
---@field private active boolean # When false, this element and its descendants do not receive inputs
---@field private _player_index number # When set, this element and its descendants only receive inputs from this player
---@field private focusable boolean
---@field private bindings { [string]: Binding }
local UIElement = Class("UIElement");

UIElement.init = function(self)
	self._joint = nil;
	self.desired_width = nil;
	self.desired_height = nil;
	self.left = nil;
	self.right = nil;
	self.top = nil;
	self.bottom = nil;
	self._color = crystal.Color.white;
	self._opacity = 1;
	self.translation_x = 0;
	self.translation_y = 0;
	self.pivot_x = 0.5;
	self.pivot_y = 0.5;
	self.scale_x = 1;
	self.scale_y = 1;
	self.active = true;
	self.player_index = nil;
	self.focusable = false;
	self.bindings = {};
end

---@param dt number
---@param width number
---@param height number
UIElement.update_tree = function(self, dt, width, height)
	assert(not self:parent());
	assert(dt);
	self:update(dt);
	self:update_desired_size();
	self:set_relative_position(0, width or self.desired_width, 0, height or self.desired_height);
	self:layout();
end

---@protected
---@param dt number
UIElement.update = function(self, dt)
end

--#region Hierarchy

---@return UIElement
UIElement.parent = function(self)
	return self._joint and self._joint:parent() or nil;
end

UIElement.remove_from_parent = function(self)
	local parent = self:parent();
	assert(parent);
	parent:remove_child(self);
end

---@return UIElement
UIElement.root = function(self)
	local parent = self:parent();
	if parent then
		return parent:root();
	end
	return self;
end

---@return boolean
UIElement.is_root = function(self)
	return self:parent() == nil;
end

---@return Joint
UIElement.joint = function(self)
	return self._joint;
end

---@param joint Joint
UIElement.set_joint = function(self, joint)
	assert(joint == nil or self._joint == nil);
	if joint == self._joint then
		return;
	end
	if self._joint then
		self:remove_alias(self._joint);
		self._joint = nil;
	end
	if joint then
		self:add_alias(joint);
		self._joint = joint;
	end
end

---@return boolean
UIElement.is_within = function(self, other)
	if other == self then
		return true;
	end
	local parent = self:parent();
	if not parent then
		return false;
	end
	return parent:is_within(other);
end

--#endregion

--#region Layout

---@return number
---@return number
---@return number
---@return number
UIElement.relative_position = function(self)
	return self.left, self.right, self.top, self.bottom;
end

---@return number
---@return number
UIElement.desired_size = function(self)
	return self.desired_width, self.desired_height;
end

---@return number
---@return number
UIElement.size = function(self)
	if not self.right or not self.left or not self.top or not self.bottom then
		error("UIElement has no size. Most likely, a call to UIElement:update_tree() is missing.");
	end
	return math.abs(self.right - self.left), math.abs(self.top - self.bottom);
end

---@protected
---@param left number
---@param right number
---@param top number
---@param bottom number
UIElement.set_relative_position = function(self, left, right, top, bottom)
	assert(left);
	assert(right);
	assert(top);
	assert(bottom);
	assert(left <= right)
	assert(top <= bottom)
	self.left = left;
	self.right = right;
	self.top = top;
	self.bottom = bottom;
end

---@protected
---@return number
---@return number
UIElement.compute_desired_size = function(self)
	return 0, 0;
end

---@protected
UIElement.update_desired_size = function(self)
	self.desired_width, self.desired_height = self:compute_desired_size();
end

---@protected
UIElement.layout = function(self)
end

--#endregion

--#region Drawing

---@param opacity number
UIElement.set_opacity = function(self, opacity)
	assert(opacity);
	assert(opacity >= 0);
	assert(opacity <= 1);
	self._opacity = opacity;
end

---@param color Color
UIElement.set_color = function(self, color)
	assert(color:inherits_from(crystal.Color));
	self._color = color;
end

---@param offset number
UIElement.set_translation_x = function(self, offset)
	self.translation_x = offset;
end

---@param offset number
UIElement.set_translation_y = function(self, offset)
	self.translation_y = offset;
end

---@param scale number
UIElement.set_scale_x = function(self, scale)
	self.scale_x = scale;
end

---@param scale number
UIElement.set_scale_y = function(self, scale)
	self.scale_y = scale;
end

UIElement.draw = function(self)
	if self._opacity == 0 then
		return;
	end
	if self.scale_x == 0 or self.scale_y == 0 then
		return;
	end

	local r, g, b, a = love.graphics.getColor();
	local width, height = self:size();
	love.graphics.push("all");

	love.graphics.setColor(r * self._color[1], g * self._color[2], b * self._color[3], a * self._opacity);
	love.graphics.translate(self.left, self.top);

	love.graphics.translate(self.translation_x, self.translation_y);
	love.graphics.translate(self.pivot_x * width, self.pivot_y * height);
	love.graphics.scale(self.scale_x, self.scale_y);
	love.graphics.translate(-self.pivot_x * width / self.scale_x, -self.pivot_y * height / self.scale_y);

	self:draw_self();

	love.graphics.pop();
end

---@protected
UIElement.draw_self = function(self)
	error("Not implemented");
end

--#endregion

--#region Input

---@param player_index number
---@param input string
---@return boolean
UIElement.handle_input = function(self, player_index, input)
	assert(self:is_root());
	assert(type(player_index) == "number");
	return self.router:route_input(self, player_index, input);
end

---@param input string
---@param relevance InputRelevance
---@param details any
---@param callback fun(player_index: number): boolean
UIElement.bind_input = function(self, input, relevance, details, callback)
	self.bindings[input] = {
		callback = callback,
		details = details,
	};
	self.router:bind_input(self, input, relevance);
end

---@param input string
UIElement.unbind_input = function(self, input)
	self.bindings[input] = nil;
	self.router:unbind_input(self, input);
end

---@return boolean
UIElement.is_active = function(self)
	return self.active;
end

---@param active boolean
UIElement.set_active = function(self, active)
	assert(type(active) == "boolean");
	self.active = active;
end

---@return number
UIElement.player_index = function(self)
	return self._player_index;
end

---@param player_index number
UIElement.set_player_index = function(self, player_index)
	assert(player_index == nil or type(player_index) == "number");
	self._player_index = player_index;
end

---@return boolean
UIElement.is_focusable = function(self)
	return self.focusable;
end

---@param focusable boolean
UIElement.set_focusable = function(self, focusable)
	assert(type(focusable) == "boolean");
	self.focusable = focusable;
end

---@param player_index number
UIElement.focus = function(self, player_index)
	assert(type(player_index) == "number");
	assert(self.focusable);
	self.router:transfer_focus(self:root(), self, player_index);
end

---@param player_index number
---@return boolean
UIElement.focus_tree = function(self, player_index)
	local first_focusable = self:first_focusable(player_index);
	if first_focusable then
		first_focusable:focus(player_index);
		return true;
	end
	return false;
end

---@param player_index number
---@return boolean
UIElement.is_focused = function(self, player_index)
	assert(type(player_index) == "number");
	return self.router:is_element_focused(self, player_index);
end

---@param player_index number
---@param direction Direction
---@return UIElement
UIElement.next_focusable = function(self, from_element, player_index, direction)
	assert(from_element:inherits_from(UIElement));
	assert(type(player_index) == "number");
	assert(direction == "up" or direction == "down" or direction == "left" or direction == "right");
	local parent = self:parent();
	if not parent then
		return nil;
	end
	return parent:next_focusable(self, player_index, direction);
end

---@param player_index number
---@return UIElement
UIElement.first_focusable = function(self, player_index)
	if self.focusable and self:can_receive_input(player_index) then
		return self;
	end
	return nil;
end

---@param player_index number
---@return boolean
UIElement.can_receive_input = function(self, player_index)
	assert(type(player_index) == "number");
	return self.router:can_element_receive_input(self:root(), self, player_index);
end

---@param input string
---@return Binding
UIElement.binding = function(self, input)
	assert(type(input) == "string");
	return self.bindings[input];
end

--#endregion

--#region Tests

crystal.test.add("Can bind/unbind input", function()
	local sentinel = false;
	local a = crystal.UIElement:new();
	a:bind_input("ui_ok", "always", nil, function()
		sentinel = true;
	end);
	a:handle_input(1, "ui_ok");
	assert(sentinel);
	sentinel = false;
	a:unbind_input("ui_ok");
	a:handle_input(1, "ui_ok");
	assert(not sentinel);
end);

crystal.test.add("Can require focus on bindings", function()
	local sentinel = false;
	local a = crystal.UIElement:new();
	a:set_focusable(true);
	a:bind_input("ui_ok", "when_focused", nil, function()
		sentinel = true;
	end);
	a:handle_input(1, "ui_ok");
	assert(not sentinel);
	a:focus(1);
	a:handle_input(1, "ui_ok");
	assert(sentinel);
end);

crystal.test.add("Calls bindings on focus path", function()
	local sentinel = false;
	local a = crystal.Overlay:new();
	local b = a:add_child(crystal.Overlay:new());
	local c = b:add_child(crystal.UIElement:new());
	b:bind_input("ui_ok", "when_focused", nil, function()
		sentinel = true;
	end);
	c:set_focusable(true);
	a:handle_input(1, "ui_ok");
	assert(not sentinel);
	c:focus(1);
	a:handle_input(1, "ui_ok");
	assert(sentinel);
end);

crystal.test.add("Can restrict inputs by player index", function()
	local sentinel = false;
	local a = crystal.UIElement:new();
	a:bind_input("ui_ok", "always", nil, function()
		sentinel = true;
	end);

	a:set_player_index(2);
	a:handle_input(1, "ui_ok");
	assert(not sentinel);

	a:set_player_index(1);
	a:handle_input(1, "ui_ok");
	assert(sentinel);
end);

crystal.test.add("Can restrict inputs by deactivating", function()
	local sentinel = false;
	local a = crystal.UIElement:new();
	a:bind_input("ui_ok", "always", nil, function()
		sentinel = true;
	end);

	a:set_active(false);
	a:handle_input(1, "ui_ok");
	assert(not sentinel);

	a:set_active(true);
	a:handle_input(1, "ui_ok");
	assert(sentinel);
end);

--#endregion

return UIElement;
