---@class SceneManager
local SceneManager = Class("SceneManager");

crystal.const.define("Time Scale", 1.0, { min = 0.0, max = 100.0 });

SceneManager.init = function(self)
	self.scene = nil;
	self.next_scene = nil;
end

---@return Scene
SceneManager.current_scene = function(self)
	return self.scene;
end

---@param next_scene Scene
---@param transition Transition
---@return Thread
SceneManager.replace = function(self, next_scene, transition)
	self.next_scene = next_scene;
end

---@param dt number
SceneManager.update = function(self, dt)
	self.scene = self.next_scene or self.scene;
	self.next_scene = nil;
	dt = dt * crystal.const.get("timescale");
	self.scene:update(dt);
end

SceneManager.draw = function(self)
	self.scene:draw();
end

return SceneManager;
