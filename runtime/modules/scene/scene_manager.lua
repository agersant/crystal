local Script = require("modules/script/script");

---@class SceneManager
local SceneManager = Class("SceneManager");

crystal.const.define("Time Scale", 1.0, { min = 0.0, max = 100.0 });

SceneManager.init = function(self)
	self.previous_scene = nil;
	self.scene = nil;
	self.next_scene = nil;
	self.transition = nil;
	self.transition_progress = 0;
	self.script = Script:new();
	self.draw_scene = function()
		if self.scene then
			self.scene:draw();
		end
	end
	self.draw_previous_scene = function()
		if self.previous_scene then
			self.previous_scene:draw();
		end
	end
end

---@return Scene
SceneManager.current_scene = function(self)
	return self.scene;
end

---@param next_scene Scene
---@param ... Transition
---@return Thread
SceneManager.replace = function(self, next_scene, ...)
	local transitions = { ... };
	local manager = self;
	self.next_scene = next_scene;

	self.script:stop_all_threads();
	return self.script:run_thread(function(self)
		self:defer(function(self)
			manager.transition = nil;
			manager.transition_progress = 0;
			manager.previous_scene = nil;
		end);
		while not table.is_empty(transitions) do
			manager.transition = table.remove(transitions, 1);
			assert(manager.transition:inherits_from(crystal.Transition));
			local start_time = self:time();
			local duration = manager.transition:duration();
			if duration > 0 then
				while self:time() < start_time + duration do
					manager.transition_progress = math.clamp((self:time() - start_time) / duration, 0, 1);
					self:wait_frame();
				end
			end
		end
	end);
end

---@param dt number
SceneManager.update = function(self, dt)
	dt = dt * crystal.const.get("timescale");
	if self.next_scene then
		self.previous_scene = self.transition and self.scene or nil;
		self.scene = self.next_scene;
		self.next_scene = nil;
	end
	self.script:update(dt);
	if self.previous_scene then
		self.previous_scene:update(dt);
	end
	if self.scene then
		self.scene:update(dt);
	end
end

SceneManager.draw = function(self)
	crystal.window.draw(function()
		if self.previous_scene then
			local width, height = crystal.window.viewport_size();
			local progress = self.transition:easing()(self.transition_progress);
			self.transition:draw(progress, width, height, self.draw_previous_scene, self.draw_scene);
		else
			self:draw_scene();
		end
	end);
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
---@param is_repeat boolean
SceneManager.key_pressed = function(self, key, scan_code, is_repeat)
	if self.scene then
		self.scene:key_pressed(key, scan_code, is_repeat);
	end
end

---@param key love.KeyConstant
---@param scan_code love.Scancode
SceneManager.key_released = function(self, key, scan_code)
	if self.scene then
		self.scene:key_released(key, scan_code);
	end
end

---@param joystick love.Joystick
---@param button love.GamepadButton
SceneManager.gamepad_pressed = function(self, joystick, button)
	if self.scene then
		self.scene:gamepad_pressed(joystick, button);
	end
end

---@param joystick love.Joystick
---@param button love.GamepadButton
SceneManager.gamepad_released = function(self, joystick, button)
	if self.scene then
		self.scene:gamepad_released(joystick, button);
	end
end

return SceneManager;
