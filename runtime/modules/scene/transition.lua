local Transition = Class("Transition");

Transition.init = function(self, duration, easing)
	assert(duration == nil or duration > 0);
	self._duration = duration or 0.2;
	self._easing = easing or math.ease_in_out_cubic;
end

Transition.duration = function(self)
	return self._duration;
end

Transition.easing = function(self)
	return self._easing;
end

Transition.draw = function(self, progress, width, height, draw_before, draw_after)
	if progress < 0.5 then
		draw_before();
	else
		draw_after();
	end
end

local Fade = Class("Fade", Transition);

Fade.init = function(self, duration, easing, color, direction)
	Fade.super.init(self, duration, easing);
	self.color = color;
	self.direction = direction;
end

Fade.draw = function(self, progress, width, height, draw_before, draw_after)
	if self.direction == "from" then
		draw_after();
	else
		draw_before();
	end
	love.graphics.setColor(self.color:alpha(self.direction == "to" and progress or (1 - progress)));
	love.graphics.rectangle("fill", 0, 0, width, height);
end

local Scroll = Class("Scroll", Transition);

Scroll.init = function(self, duration, easing, x, y)
	Scroll.super.init(self, duration, easing);
	self.x = x;
	self.y = y;
end

Scroll.draw = function(self, progress, width, height, draw_before, draw_after)
	love.graphics.push();
	local dx = self.x * progress * width;
	local dy = self.y * progress * height;
	love.graphics.translate(dx, dy);
	draw_before();
	love.graphics.pop();

	local dx = self.x * (progress - 1) * width;
	local dy = self.y * (progress - 1) * height;
	love.graphics.translate(dx, dy);
	draw_after();
end

Transition.FadeToBlack = Class("FadeToBlack", Fade);
Transition.FadeToBlack.init = function(self, duration, easing)
	Transition.FadeToBlack.super.init(self, duration, easing, crystal.Color.black, "to");
end
Transition.FadeFromBlack = Class("FadeFromBlack", Fade);
Transition.FadeFromBlack.init = function(self, duration, easing)
	Transition.FadeFromBlack.super.init(self, duration, easing, crystal.Color.black, "from");
end

Transition.ScrollLeft = Class("ScrollLeft", Scroll);
Transition.ScrollLeft.init = function(self, duration, easing)
	Transition.ScrollLeft.super.init(self, duration, easing, -1, 0);
end

Transition.ScrollRight = Class("ScrollRight", Scroll);
Transition.ScrollRight.init = function(self, duration, easing)
	Transition.ScrollRight.super.init(self, duration, easing, 1, 0);
end

Transition.ScrollUp = Class("ScrollUp", Scroll);
Transition.ScrollUp.init = function(self, duration, easing)
	Transition.ScrollUp.super.init(self, duration, easing, 0, -1);
end

Transition.ScrollDown = Class("ScrollDown", Scroll);
Transition.ScrollDown.init = function(self, duration, easing)
	Transition.ScrollDown.super.init(self, duration, easing, 0, 1);
end

return Transition;
