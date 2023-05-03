---@alias MouseTarget { left: number, right: number, top: number, bottom: number, recipient: any }

---@class MouseRouter
---@field private targets MouseTarget[]
---@field private _recipient any
local MouseRouter = Class("MouseRouter");

MouseRouter.init = function(self)
	self.targets = {};
	self._recipient = nil;
end

---@return any
MouseRouter.recipient = function(self)
	return self._recipient;
end

---@param recipient any
---@param left number
---@param right number
---@param top number
---@param bottom number
MouseRouter.add_target = function(self, recipient, left, right, top, bottom)
	assert(recipient);
	assert(right >= left);
	assert(bottom >= top);
	table.push(self.targets, {
		left = left,
		right = right,
		top = top,
		bottom = bottom,
		recipient = recipient,
	});
end

MouseRouter.update = function(self)
	self._recipient = nil;
	local mx, my = love.mouse.getPosition();
	-- TODO Consider using a quadtree for this
	for i = #self.targets, 1, -1 do
		local target = self.targets[i];
		-- TODO needs to respect UI element active/player_index requirements
		if mx >= target.left and mx <= target.right and my >= target.top and my <= target.bottom then
			self._recipient = target.recipient;
			break;
		end
	end
	self.targets = {};
end

return MouseRouter;
