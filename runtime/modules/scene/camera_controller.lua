local Script = require("modules/script/script");

---@class CameraController
---@field private _camera Camera
---@field private next_camera Camera
---@field private script Script
---@field private transition Transition
---@field private transition_camera Camera
---@field private transition_progress number
---@field private move_x number
---@field private move_y number
local CameraController = Class("CameraController");

CameraController.init = function(self)
	self._camera = nil;
	self.next_camera = nil;
	self.latest_camera = nil;
	self.script = Script:new();
	self.transition = nil;
	self.transition_camera = nil;
	self.transition_progress = nil;
	self.move_x = nil;
	self.move_y = nil;
end

---@param dt number
CameraController.update = function(self, dt)
	self.script:update(dt);
end

---@param draw fun()
CameraController.draw = function(self, draw)
	local width, height = crystal.window.viewport_size();
	if self.transition then
		self.transition:draw(
			self.transition_progress, width, height,
			function()
				self.transition_camera = self._camera;
				self:draw_with_camera(self._camera, draw);
			end,
			function()
				self.transition_camera = self.next_camera;
				self:draw_with_camera(self.next_camera, draw);
			end
		);
	elseif self.move_x and self.move_y then
		love.graphics.translate(self.move_x, self.move_y);
		draw();
	else
		self:draw_with_camera(self._camera, draw);
	end
end

---@return Camera
CameraController.camera = function(self)
	if self.transition then
		return self.transition_camera or self._camera;
	elseif self.move_x and self.move_y then
		return self.next_camera;
	else
		return self._camera;
	end
end

---@return number
---@return number
CameraController.offset = function(self)
	if self.transition then
		local camera = self.transition_camera or self._camera;
		return self:offset_for_camera(camera);
	elseif self.move_x and self.move_y then
		return self.move_x, self.move_y;
	else
		return self:offset_for_camera(self._camera);
	end
end

---@param camera Camera
---@param ... Transition
CameraController.cut_to = function(self, camera, ...)
	assert(camera:inherits_from(crystal.Camera));
	local transitions = { ... };
	local controller = self;
	self.next_camera = camera;

	self.script:stop_all_threads();
	return self.script:run_thread(function(self)
		self:defer(function(self)
			controller.transition = nil;
			controller.transition_camera = nil;
			controller.transition_progress = 0;
			controller.next_camera = nil;
		end);

		while not table.is_empty(transitions) do
			controller.transition = table.remove(transitions, 1);
			assert(controller.transition:inherits_from(crystal.Transition));
			local start_time = self:time();
			local duration = controller.transition:duration();
			if duration > 0 then
				while self:time() < start_time + duration do
					controller.transition_progress = math.clamp((self:time() - start_time) / duration, 0, 1);
					self:wait_frame();
				end
			end
		end

		controller._camera = camera;
	end);
end

---@param camera Camera
---@param duration number
---@param easing fun(t: number): number
CameraController.move_to = function(self, camera, duration, easing)
	assert(camera:inherits_from(crystal.Camera));
	assert(duration > 0);
	easing = easing or math.ease_linear;
	local controller = self;
	self.next_camera = camera;

	self.script:stop_all_threads();
	return self.script:run_thread(function(self)
		self:defer(function(self)
			controller.move_x = nil;
			controller.move_y = nil;
			controller.next_camera = nil;
		end);

		local start_time = self:time();
		while self:time() < start_time + duration do
			local progress = easing(math.clamp((self:time() - start_time) / duration, 0, 1));
			local from_x, from_y = controller:offset_for_camera(controller._camera);
			local to_x, to_y = controller:offset_for_camera(controller.next_camera);
			controller.move_x = math.lerp(from_x, to_x, progress);
			controller.move_y = math.lerp(from_y, to_y, progress);
			self:wait_frame();
		end

		controller._camera = camera;
	end);
end

---@private
---@return number
---@return number
CameraController.draw_with_camera = function(self, camera, draw)
	local ox, oy = self:offset_for_camera(camera);
	love.graphics.push();
	love.graphics.translate(ox, oy);
	draw();
	love.graphics.pop();
end

---@private
---@return number
---@return number
CameraController.offset_for_camera = function(self, camera)
	if not camera then
		return 0, 0;
	end
	local cx, cy = camera:position();
	local w, h = crystal.window.viewport_size();
	local draw_x = math.round(w / 2) - math.round(cx);
	local draw_y = math.round(h / 2) - math.round(cy);
	return draw_x, draw_y;
end

return CameraController;
