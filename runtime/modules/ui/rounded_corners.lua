local Painter = require(CRYSTAL_RUNTIME .. "modules/ui/painter");

local shader_source = [[
	uniform vec4 radii; // In pixels (top-left, top-right, bottom-right, bottom-left)
	uniform vec2 texture_size; // In pixels
	uniform vec2 draw_size; // In pixels

	// Reference: https://www.shadertoy.com/view/3tj3Dm
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec4 texture_color = Texel(texture, texture_coords);
		vec4 out_color = texture_color * color;

		// Position within the rectangle, in range [-0.5, 0.5]
		vec2 pos = texture_coords * texture_size / draw_size - vec2(0.5);

		vec2 quadrant = step(pos, vec2(0.0));
		float radius = mix(
			mix(radii.z, radii.y, quadrant.y),
			mix(radii.w, radii.x, quadrant.y),
			quadrant.x
		);

		if (radius > 0) {
			float distance_to_center = length(max(abs(pos * draw_size) + vec2(radius) - draw_size * vec2(0.5), 0.0));
			out_color *= smoothstep(-0.5, 0.5, radius - distance_to_center);
		}

		return out_color;
	}
]];

local shader;

---@class RoundedCorners : Painter
---@field private radius_top_left number
---@field private radius_top_right number
---@field private radius_bottom_right number
---@field private radius_bottom_left number
local RoundedCorners = Class("RoundedCorners", Painter);

RoundedCorners.init = function(self, radius)
	if not shader then
		shader = love.graphics.newShader(shader_source);
	end
	RoundedCorners.super.init(self, shader);
	self:set_radius(radius or 2);
end

---@param radius number
RoundedCorners.set_radius_top_left = function(self, radius)
	assert(type(radius) == "number" and radius >= 0);
	self.radius_top_left = radius;
end

---@param radius number
RoundedCorners.set_radius_top_right = function(self, radius)
	assert(type(radius) == "number" and radius >= 0);
	self.radius_top_right = radius;
end

---@param radius number
RoundedCorners.set_radius_bottom_right = function(self, radius)
	assert(type(radius) == "number" and radius >= 0);
	self.radius_bottom_right = radius;
end

---@param radius number
RoundedCorners.set_radius_bottom_left = function(self, radius)
	assert(type(radius) == "number" and radius >= 0);
	self.radius_bottom_left = radius;
end

---@param top_left_or_all number
---@overload fun(self: RoundedCorners, left_or_all: number, top_right: number, bottom_right: number, bottom_left: number)
RoundedCorners.set_radius = function(self, top_left_or_all, top_right, bottom_right, bottom_left)
	assert(type(top_left_or_all) == "number");
	if type(top_right) == "number" then
		assert(type(bottom_right) == "number");
		assert(type(bottom_left) == "number");
		self:set_radius_top_left(top_left_or_all);
		self:set_radius_top_right(top_right);
		self:set_radius_bottom_right(bottom_right);
		self:set_radius_bottom_left(bottom_left);
	else
		assert(top_right == nil);
		assert(bottom_right == nil);
		assert(bottom_left == nil);
		self:set_radius_top_left(top_left_or_all);
		self:set_radius_top_right(top_left_or_all);
		self:set_radius_bottom_right(top_left_or_all);
		self:set_radius_bottom_left(top_left_or_all);
	end
end

---@protected
---@param shader love.Shader
---@param quad love.Quad
RoundedCorners.configure_shader = function(self, shader, quad)
	local radii = { self.radius_top_left, self.radius_top_right, self.radius_bottom_right, self.radius_bottom_left };
	shader:send("radii", radii);
	shader:send("draw_size", { self:size() });
	shader:send("texture_size", { quad:getTextureDimensions() });
end

return RoundedCorners;
