---@class Tool
---@field visible boolean
local Tool = Class("Tool");

Tool.init = function(self)
end

---@param dt number
Tool.update = function(self, dt)
end

Tool.draw = function(self)
end

Tool.show = function(self)
end

Tool.hide = function(self)
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
Tool.key_pressed = function(self, key, scan_code, is_repeat)
end

---@param text string
Tool.text_input = function(self, text)
end

return Tool;
