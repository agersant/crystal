---@class Scene
local Scene = Class("Scene");

---@param dt number
Scene.update = function(self, dt)
end

Scene.draw = function(self)
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
Scene.key_pressed = function(self, key, scan_code, is_repeat)
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
Scene.key_released = function(self, key, scan_code)
end

---@param joystick love.Joystick
---@param button love.GamepadButton
Scene.gamepad_pressed = function(self, joystick, button)
end

---@param joystick love.Joystick
---@param button love.GamepadButton
Scene.gamepad_released = function(self, joystick, button)
end

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param presses number
Scene.mouse_pressed = function(self, x, y, button, is_touch, presses)
end

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param presses number
Scene.mouse_released = function(self, x, y, button, is_touch, presses)
end

---@param player_index number
---@param action string
Scene.action_pressed = function(self, player_index, action)
end

---@param player_index number
---@param action string
Scene.action_released = function(self, player_index, action)
end

return Scene;
