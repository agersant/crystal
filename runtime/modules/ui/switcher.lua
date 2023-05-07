local Transition = require(CRYSTAL_RUNTIME .. "/modules/scene/transition");
local BasicJoint = require(CRYSTAL_RUNTIME .. "/modules/ui/basic_joint");
local Container = require(CRYSTAL_RUNTIME .. "/modules/ui/container");

---@alias SwitcherSizingMode "largest" | "active"

---@class Switcher : Container
---@field private _active_child UIElement
---@field private _sizing_mode SwitcherSizingMode
---@field private previous_child UIElement
---@field private script Script
---@field private transition Transition
---@field private transition_progress number
---@field private draw_active fun()
---@field private draw_previous fun()
local Switcher = Class("Switcher", Container);

Switcher.init = function(self)
	Switcher.super.init(self, BasicJoint);
	self._active_child = nil;
	self._sizing_mode = "active";
	self.script = crystal.Script:new();
	self.transition = nil;
	self.transition_progress = nil;
	self.draw_active = function()
		if self._active_child then
			self._active_child:draw();
		end
	end
	self.draw_previous = function()
		if self.previous_child then
			self.previous_child:draw();
		end
	end
end

---@return SwitcherSizingMode
Switcher.sizing_mode = function(self)
	return self._sizing_mode;
end

---@param mode SwitcherSizingMode
Switcher.set_sizing_mode = function(self, mode)
	assert(mode == "largest" or mode == "active");
	self._sizing_mode = mode;
end

---@return UIElement
Switcher.active_child = function(self)
	return self._active_child;
end

---@param child UIElement
Switcher.add_child = function(self, child)
	local was_empty = #self._children == 0;
	local child = Switcher.super.add_child(self, child);
	assert(child:parent() == self);
	if was_empty then
		self:switch_to(child);
	end
	return child;
end

---@param child UIElement
Switcher.remove_child = function(self, child)
	Switcher.super.remove_child(self, child);
	if self.previous_child == child then
		self.previous_child = nil;
	end
	if self._active_child == child then
		self._active_child = nil;
	end
end

---@param child UIElement
---@param ... Transition
---@return Thread
Switcher.switch_to = function(self, child, ...)
	assert(not child or child:parent() == self);
	if self._active_child == child then
		return;
	end

	self.script:stop_all_threads();

	local switcher = self;
	local transitions = { ... };
	self.previous_child = self._active_child;
	self._active_child = child;

	return self.script:run_thread(function(self)
		self:defer(function(self)
			switcher.transition = nil;
			switcher.transition_progress = nil;
			switcher.previous_child = nil;
		end);
		while not table.is_empty(transitions) do
			switcher.transition = table.remove(transitions, 1);
			assert(switcher.transition:inherits_from(crystal.Transition));
			local start_time = self:time();
			local duration = switcher.transition:duration();
			local easing = switcher.transition:easing();
			if duration > 0 then
				while self:time() < start_time + duration do
					switcher.transition_progress = easing((self:time() - start_time) / duration);
					self:wait_frame();
				end
			end
		end
	end);
end

---@protected
---@return number
---@return number
Switcher.compute_desired_size = function(self)
	if self._sizing_mode == "active" then
		local previous_width, previous_height;
		if self.previous_child then
			local joint = self.child_joints[self.previous_child];
			previous_width, previous_height = joint:compute_desired_size(self.previous_child:desired_size());
		end

		local active_width, active_height;
		if self._active_child then
			local joint = self.child_joints[self._active_child];
			active_width, active_height = joint:compute_desired_size(self._active_child:desired_size());
		end

		if previous_width and active_width then
			assert(self.transition_progress);
			local width = math.lerp(previous_width, active_width, self.transition_progress);
			local height = math.lerp(previous_height, active_height, self.transition_progress);
			return width, height;
		elseif active_width then
			return active_width, active_height;
		elseif previous_width then
			return previous_width, previous_height;
		else
			return 0, 0;
		end
	else
		-- Size to bounding box of all children
		local width, height = 0, 0;
		for child, joint in pairs(self.child_joints) do
			local child_width, child_height = child:desired_size();
			child_width, child_height = joint:compute_desired_size(child_width, child_height);
			width = math.max(width, child_width);
			height = math.max(height, child_height);
		end
		return width, height;
	end
end

---@protected
Switcher.arrange_children = function(self)
	local width, height = self:size();
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		local child_width, child_height = child:desired_size();
		local left, right, top, bottom = joint:compute_relative_position(child_width, child_height, width, height);
		child:set_relative_position(left, right, top, bottom);
	end
end

---@protected
---@param dt number
Switcher.update = function(self, dt)
	Switcher.super.update(self, dt);
	self.script:update(dt);
end

---@protected
Switcher.draw_self = function(self)
	if self.transition then
		local width, height = self:size();
		self.transition:draw(self.transition_progress, width, height, self.draw_previous, self.draw_active);
	else
		self._active_child:draw();
	end
end

--#region Tests

local TestTransition = Class:test("TestTransition", Transition);

TestTransition.init = function(self)
	TestTransition.super.init(self, 10, math.ease_linear);
end

TestTransition.draw = function(self, t, width, height, before, after)
	self.drawn_at_progress = t;
end

crystal.test.add("Shows first child by default", function()
	local drawn = {};
	local draw = function(self)
		drawn[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(crystal.UIElement:new());
	b.draw_self = draw;
	switcher:update_tree(0);
	switcher:draw_tree();
	assert(drawn[a]);
	assert(not drawn[b]);
end);

crystal.test.add("Can snap to different child", function()
	local drawn = {};
	local draw = function(self)
		drawn[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(crystal.UIElement:new());
	b.draw_self = draw;
	switcher:switch_to(b);
	switcher:update_tree(0);
	switcher:draw_tree();
	assert(not drawn[a]);
	assert(drawn[b]);
end);

crystal.test.add("Supports dynamic or fixed desired size", function()
	for _, test in pairs({
		{ sizing = "active",  expected_size = { 0, 50, 0, 100 } },
		{ sizing = "largest", expected_size = { 0, 100, 0, 100 } },
	}) do
		local switcher = Switcher:new();
		local a = switcher:add_child(crystal.Image:new());
		a:set_image_size(50, 100);
		local b = switcher:add_child(crystal.Image:new());
		b:set_image_size(100, 50);
		switcher:set_sizing_mode(test.sizing);
		switcher:update_tree(0);
		assert(table.equals(test.expected_size, { switcher:relative_position() }));
	end
end);

crystal.test.add("Applies transition draw function during transition", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:switch_to(b, transition);
	switcher:update_tree(5);
	switcher:draw_tree();
	assert(transition.drawn_at_progress == 0.5);
end);

crystal.test.add("Can interrupt a transition by starting another one", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());

	switcher:switch_to(b, transition);
	switcher:update_tree(5);
	switcher:draw_tree();
	assert(transition.drawn_at_progress == 0.5);

	switcher:switch_to(a, transition);
	switcher:update_tree(2);
	switcher:draw_tree();
	assert(transition.drawn_at_progress == 0.2);
end);

crystal.test.add("Ignores transition to active child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:switch_to(b, transition);
	switcher:update_tree(5);
	switcher:switch_to(b, transition);
	switcher:update_tree(2);
	switcher:draw_tree();
	assert(transition.drawn_at_progress == 0.7);
end);

--#endregion

return Switcher;
