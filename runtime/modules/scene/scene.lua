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

return Scene;
