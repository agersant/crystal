local w = 136;
local h = 136;
local ox = 71;
local oy = 67;

-- TODO split giant strip into more square texture

return {
	type = "spritesheet",
	content = {
		texture = "assets/texture/sprite/sahagin.png",
		frames = {
			attack_left_2 = { x = 0 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			attack_left_1 = { x = 1 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } }, hit = { rect = { x = -34, y = -8, w = 24, h = 8 } } } },
			attack_left_0 = { x = 2 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_left_1 = 	{ x = 3 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_left_0 = 	{ x = 4 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			idle_left = 	{ x = 5 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },

			attack_right_2 = 	{ x = 6 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			attack_right_1 = 	{ x = 7 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } }, hit = { rect = { x = 10, y = -8, w = 24, h = 8 } } } },
			attack_right_0 = 	{ x = 8 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_right_1 = 		{ x = 9 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_right_0 = 		{ x = 10 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			idle_right = 		{ x = 11 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },

			attack_up_2 = 	{ x = 12 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			attack_up_1 =	{ x = 13 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } }, hit = { rect = { x = 0, y = -40, w = 8, h = 24 } } } },
			attack_up_0 = 	{ x = 14 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_up_1 = 	{ x = 15 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_up_0 = 	{ x = 16 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			idle_up = 		{ x = 17 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },

			attack_down_2 = { x = 18 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			attack_down_1 =	{ x = 19 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } }, hit = { rect = { x = -8, y = 0, w = 8, h = 24 } } } },
			attack_down_0 = { x = 20 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_down_1 = 	{ x = 21 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			walk_down_0 = 	{ x = 22 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },
			idle_down = 	{ x = 23 * w, y = 0, w = w, h = w, ox = ox, oy = oy, tags = { weak = { rect = { x = -4, y = -12, w = 8, h = 12 } } } },

			knockback = 	{ x = 24 * w, y = 0, w = w, h = w, ox = ox, oy = oy, },
			smashed = 		{ x = 25 * w, y = 0, w = w, h = w, ox = ox, oy = oy, },
		},
		animations = {
			idle_down = { frames = { { id = "idle_down" } } },
			idle_up = { frames = { { id = "idle_up" } } },
			idle_right = { frames = { { id = "idle_right" } } },
			idle_left = { frames = { { id = "idle_left" } } },
			walk_down = { loop = true, frames = {
				{ id = "walk_down_0", duration = 0.15 },
				{ id = "idle_down", duration = 0.15 },
				{ id = "walk_down_1", duration = 0.15 },
				{ id = "idle_down", duration = 0.15 },
			} },
			walk_up = { loop = true, frames = {
				{ id = "walk_up_0", duration = 0.15 },
				{ id = "idle_up", duration = 0.15 },
				{ id = "walk_up_1", duration = 0.15 },
				{ id = "idle_up", duration = 0.15 },
			} },
			walk_left = { loop = true, frames = {
				{ id = "walk_left_0", duration = 0.15 },
				{ id = "idle_left", duration = 0.15 },
				{ id = "walk_left_1", duration = 0.15 },
				{ id = "idle_left", duration = 0.15 },
			} },
			walk_right = { loop = true, frames = {
				{ id = "walk_right_0", duration = 0.15 },
				{ id = "idle_right", duration = 0.15 },
				{ id = "walk_right_1", duration = 0.15 },
				{ id = "idle_right", duration = 0.15 },
			} },
			attack_down = { loop = false, frames = {
				{ id = "attack_down_0", duration = 0.3 },
				{ id = "attack_down_1", duration = 0.08 },
				{ id = "attack_down_2", duration = 0.08 },
			} },
			attack_up = { loop = false, frames = {
				{ id = "attack_up_0", duration = 0.3 },
				{ id = "attack_up_1", duration = 0.08 },
				{ id = "attack_up_2", duration = 0.08 },
			} },
			attack_right = { loop = false, frames = {
				{ id = "attack_right_0", duration = 0.3 },
				{ id = "attack_right_1", duration = 0.08 },
				{ id = "attack_right_2", duration = 0.08 },
			} },
			attack_left = { loop = false, frames = {
				{ id = "attack_left_0", duration = 0.3 },
				{ id = "attack_left_1", duration = 0.08 },
				{ id = "attack_left_2", duration = 0.08 },
			} },
			knockback_down = { frames = { { id = "knockback" } } },
			knockback_up = { frames = { { id = "knockback" } } },
			knockback_right = { frames = { { id = "knockback" } } },
			knockback_left = { frames = { { id = "knockback" } } },
			death = { frames = { { id = "smashed" } } },
		},
	},
};