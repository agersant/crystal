---@alias MouseRecipient { overlaps_mouse: nil | fun(self: MouseRecipient, player_index: number, mouse_x: number, mouse_y: number): boolean }
---@alias MouseTarget { left: number, right: number, top: number, bottom: number, recipient: MouseRecipient }

---@class MouseRouter
---@field private targets MouseTarget[]
---@field private _recipient MouseRecipient
---@field private mouse_api MouseAPI
local MouseRouter = Class("MouseRouter");

MouseRouter.init = function(self, mouse_api)
	assert(mouse_api);
	self.targets = {};
	self._recipient = nil;
	self.mouse_api = mouse_api;
end

---@return MouseRecipient
MouseRouter.recipient = function(self)
	return self._recipient;
end

---@param recipient MouseRecipient
---@param left number
---@param right number
---@param top number
---@param bottom number
MouseRouter.add_target = function(self, recipient, left, right, top, bottom)
	assert(type(recipient) == "table");
	assert(right >= left);
	assert(bottom >= top);
	-- TODO Consider using a quadtree for this
	table.push(self.targets, {
		left = left,
		right = right,
		top = top,
		bottom = bottom,
		recipient = recipient,
	});
end

---@param player_index number
MouseRouter.update = function(self, player_index)
	assert(type(player_index) == "number");
	local mx, my = self.mouse_api:position();
	self._recipient = nil;
	for i = #self.targets, 1, -1 do
		local target = self.targets[i];
		local inside_x = mx >= target.left and mx <= target.right;
		local inside_y = my >= target.top and my <= target.bottom;
		if inside_x and inside_y then
			local overlap_test = target.recipient.overlaps_mouse;
			if overlap_test == nil or overlap_test(target.recipient, player_index, mx, my) then
				self._recipient = target.recipient;
				break;
			end
		end
	end
	self.targets = {};
end

return MouseRouter;
