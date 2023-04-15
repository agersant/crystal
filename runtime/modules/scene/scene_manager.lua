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
	return self.script:add_thread(function(self)
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
		manager.transition = nil;
		manager.transition_progress = 0;
		manager.previous_scene = nil;
	end);
end

---@param dt number
SceneManager.update = function(self, dt)
	dt = dt * crystal.const.get("timescale");
	if self.next_scene then
		self.previous_scene = self.scene;
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
		if not self.transition then
			if self.scene then
				self.scene:draw();
			end
		else
			local width, height = crystal.window.viewport_size();
			local progress = self.transition:easing()(self.transition_progress);
			self.transition:draw(progress, width, height, self.draw_previous_scene, self.draw_scene);
		end
	end);
end

return SceneManager;
