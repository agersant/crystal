---@class SceneManager
---@field private previous_scene Scene
---@field private scene Scene
---@field private next_scene Scene
---@field private transition Transition
---@field private transition_progress number
---@field private script Script
---@field private draw_scene fun()
---@field private draw_previous_scene fun()
local SceneManager = Class("SceneManager");

crystal.const.define("TimeScale", 1.0, { min = 0.0, max = 100.0 });

SceneManager.init = function(self)
	self.previous_scene = nil;
	self.scene = nil;
	self.next_scene = nil;
	self.transition = nil;
	self.transition_progress = 0;
	self.script = crystal.Script:new();
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
	return self.next_scene or self.scene;
end

---@param next_scene Scene
---@param ... Transition
---@return Thread
SceneManager.replace = function(self, next_scene, ...)
	self.script:stop_all_threads();
	self.next_scene = next_scene;
	local transitions = { ... };
	local manager = self;

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
			local easing = manager.transition:easing();
			if duration > 0 then
				while self:time() < start_time + duration do
					manager.transition_progress = easing((self:time() - start_time) / duration);
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
			self.transition:draw(self.transition_progress, width, height, self.draw_previous_scene, self.draw_scene);
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

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param preses number
SceneManager.mouse_pressed = function(self, x, y, button, is_touch, presses)
	if self.scene then
		self.scene:mouse_pressed(x, y, button, is_touch, presses);
	end
end

---@param x number
---@param y number
---@param button number
---@param is_touch boolean
---@param preses number
SceneManager.mouse_released = function(self, x, y, button, is_touch, presses)
	if self.scene then
		self.scene:mouse_released(x, y, button, is_touch, presses);
	end
end

--#region Tests

crystal.test.add("Can replace scene without transition", function()
	local manager = SceneManager:new();
	local old_scene = crystal.Scene:new();
	local new_scene = crystal.Scene:new();
	assert(manager:current_scene() == nil);

	manager:replace(old_scene);
	assert(manager:current_scene() == old_scene);
	manager:update(0);
	assert(manager:current_scene() == old_scene);

	manager:replace(new_scene);
	assert(manager:current_scene() == new_scene);
	manager:update(0);
	assert(manager:current_scene() == new_scene);
end);

crystal.test.add("Forwards callbacks to current scene", function()
	local scene = crystal.Scene:new();
	local callbacks = {};
	scene.update = function() callbacks.update = true; end;
	scene.draw = function() callbacks.draw = true; end;
	scene.key_pressed = function() callbacks.key_pressed = true; end;
	scene.key_released = function() callbacks.key_released = true; end;
	scene.gamepad_pressed = function() callbacks.gamepad_pressed = true; end;
	scene.gamepad_released = function() callbacks.gamepad_released = true; end;
	scene.mouse_pressed = function() callbacks.mouse_pressed = true; end;
	scene.mouse_released = function() callbacks.mouse_released = true; end;

	local manager = SceneManager:new();
	manager:replace(scene);

	manager:update(0);
	assert(callbacks.update);
	manager:draw();
	assert(callbacks.draw);
	manager:key_pressed("z");
	assert(callbacks.key_pressed);
	manager:key_released("z");
	assert(callbacks.key_released);
	manager:gamepad_pressed("a");
	assert(callbacks.gamepad_pressed);
	manager:gamepad_released("a");
	assert(callbacks.gamepad_released);
	manager:mouse_pressed(0, 0);
	assert(callbacks.mouse_pressed);
	manager:mouse_released(0, 0);
	assert(callbacks.mouse_released);
end);

crystal.test.add("Can draw scene transition", function(context)
	local manager = SceneManager:new();

	local old_scene = crystal.Scene:new();
	old_scene.draw = function()
		love.graphics.setColor(1, 0, 0);
		love.graphics.rectangle("fill", 0, 0, 100, 100);
	end

	local new_scene = crystal.Scene:new();
	new_scene.draw = function()
		love.graphics.setColor(1, 1, 0);
		love.graphics.rectangle("fill", 0, 0, 50, 50);
	end

	local transition = crystal.Transition:new();
	transition.draw = function(self, progress, width, height, before, after)
		before();
		after();
	end

	manager:replace(old_scene);
	manager:update(0);
	manager:replace(new_scene, transition);
	manager:update(0);
	manager:draw();
	context:expect_frame("test-data/can-draw-scene-transition.png");
end);

crystal.test.add("Updates both scenes during transition", function()
	local manager = SceneManager:new();

	local old_scene = crystal.Scene:new();
	local old_updates = 0;
	old_scene.update = function()
		old_updates = old_updates + 1;
	end

	local new_scene = crystal.Scene:new();
	local new_updates = 0;
	new_scene.update = function()
		new_updates = new_updates + 1;
	end

	manager:replace(old_scene);
	manager:update(0);
	assert(old_updates == 1);
	assert(new_updates == 0);

	manager:replace(new_scene, crystal.Transition:new(1));
	manager:update(0.8);
	assert(old_updates == 2);
	assert(new_updates == 1);

	manager:update(0.8);
	assert(old_updates == 2);
	assert(new_updates == 2);

	manager:update(0.8);
	assert(old_updates == 2);
	assert(new_updates == 3);
end);

--#endregion

return SceneManager;
