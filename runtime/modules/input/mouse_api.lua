local features = require(CRYSTAL_RUNTIME .. "features");

---@class MouseAPI
local MouseAPI = Class("MouseAPI");

MouseAPI.position = function(self)
	return love.mouse.getPosition();
end

if features.tests then
	MouseAPI.Mock = Class("MouseAPI.Mock", MouseAPI);

	MouseAPI.Mock.init = function(self)
		self.x = 0;
		self.y = 0;
	end

	---@return number
	---@return number
	MouseAPI.Mock.position = function(self)
		return self.x, self.y;
	end

	---@param x number
	---@param y number
	MouseAPI.Mock.set_position = function(self, x, y)
		self.x = x;
		self.y = y;
	end
end

return MouseAPI;
