return {
	type = "spritesheet",
	content = {
		texture = "assets/texture/sprite/duran.png",
		frames = {
			idle_down = 	{ x = 0, y = 0, w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			idle_up = 		{ x = 0, y = 64, w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			idle_right = 	{ x = 0, y = 128, w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			idle_left = 	{ x = 0, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			walk_down_0 = 	{ x = 320 + 0 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_down_1 = 	{ x = 320 + 1 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_down_2 = 	{ x = 320 + 2 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_down_3 = 	{ x = 320 + 3 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_down_4 = 	{ x = 320 + 4 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_down_5 = 	{ x = 320 + 5 * 64, y = 0 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			walk_up_0 = 	{ x = 320 + 0 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_up_1 = 	{ x = 320 + 1 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_up_2 = 	{ x = 320 + 2 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_up_3 = 	{ x = 320 + 3 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_up_4 = 	{ x = 320 + 4 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_up_5 = 	{ x = 320 + 5 * 64, y = 64 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			walk_right_0 = 	{ x = 320 + 0 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_right_1 = 	{ x = 320 + 1 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_right_2 = 	{ x = 320 + 2 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_right_3 = 	{ x = 320 + 3 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_right_4 = 	{ x = 320 + 4 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_right_5 = 	{ x = 320 + 5 * 64, y = 128 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			walk_left_0 = 	{ x = 320 + 0 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_left_1 = 	{ x = 320 + 1 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_left_2 = 	{ x = 320 + 2 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_left_3 = 	{ x = 320 + 3 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_left_4 = 	{ x = 320 + 4 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			walk_left_5 = 	{ x = 320 + 5 * 64, y = 192 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_down_0_0 = { x = 0 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_0_1 = { x = 1 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_0_2 = { x = 2 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -12, y = -10, w = 32, h = 18 } } } },
			attack_down_0_3 = { x = 3 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_down_1_0 = { x = 4 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 48, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_1_1 = { x = 5 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_1_2 = { x = 6 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -4, y = -10, w = 8, h = 24 } } } },
			attack_down_1_3 = { x = 7 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_down_2_0 = { x = 8 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 51, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_2_1 = { x = 9 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 51, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_2_2 = { x = 10 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 51, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -4, y = -10, w = 8, h = 24 } } } },
			attack_down_2_3 = { x = 11 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 51, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_down_3_0 = { x = 12 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 45, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_3_1 = { x = 13 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 45, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_down_3_2 = { x = 14 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 45, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -4, y = -10, w = 8, h = 24 } } } },
			attack_down_3_3 = { x = 15 * 64, y = 512 , w = 64, h = 64, ox = 30, oy = 45, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_up_0_0 = 	{ x = 0 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_up_0_1 = 	{ x = 1 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_up_0_2 = 	{ x = 2 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -12, y = -10, w = 32, h = -18 } } } },
			attack_up_0_3 = 	{ x = 3 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_up_1_0 = { x = 4 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 48, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_up_1_1 = { x = 5 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_up_1_2 = { x = 6 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -5, y = -37, w = 8, h = 24 } } } },
			attack_up_1_3 = { x = 7 * 64, y = 576 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_right_0_0 = { x = 0 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_right_0_1 = { x = 1 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_right_0_2 = { x = 2 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = 4, y = -32, w = 18, h = 32 } } } },
			attack_right_0_3 = { x = 3 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_right_1_0 = { x = 4 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 48, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_right_1_1 = { x = 5 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_right_1_2 = { x = 6 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = 6, y = -10, w = 24, h = 8 } } } },
			attack_right_1_3 = { x = 7 * 64, y = 640 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_left_0_0 = { x = 0 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_left_0_1 = { x = 1 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_left_0_2 = { x = 2 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = 0, y = -32, w = -18, h = 32 } } } },
			attack_left_0_3 = { x = 3 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 52, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			attack_left_1_0 = { x = 4 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 48, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_left_1_1 = { x = 5 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },
			attack_left_1_2 = { x = 6 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } }, hit = { rect = { x = -29, y = -9, w = 24, h = 8 } } } },
			attack_left_1_3 = { x = 7 * 64, y = 704 , w = 64, h = 64, ox = 30, oy = 46, tags = { weak = { rect = { x = -4, y = -16, w = 8, h = 16 } } } },

			knockback_down = 	{ x = 768, y = 5 * 64 , w = 64, h = 64, ox = 30, oy = 52, },
			knockback_up = 		{ x = 768, y = 4 * 64 , w = 64, h = 64, ox = 30, oy = 52, },
			knockback_right = 	{ x = 768, y = 7 * 64 , w = 64, h = 64, ox = 30, oy = 52, },
			knockback_left = 	{ x = 768, y = 6 * 64 , w = 64, h = 64, ox = 30, oy = 52, },

			death_0 = { x = 1 * 64, y = 832 , w = 64, h = 64, ox = 30, oy = 52 },
			death_1 = { x = 2 * 64, y = 832 , w = 64, h = 64, ox = 30, oy = 52 },
		},
		animations = {
			idle_down = { frames = { { id = "idle_down" } } },
			idle_up = { frames = { { id = "idle_up" } } },
			idle_right = { frames = { { id = "idle_right" } } },
			idle_left = { frames = { { id = "idle_left" } } },
			walk_down = { loop = true, frames = {
				{ id = "walk_down_0", duration = 0.16 },
				{ id = "walk_down_1", duration = 0.16 },
				{ id = "walk_down_2", duration = 0.16 },
				{ id = "walk_down_3", duration = 0.16 },
				{ id = "walk_down_4", duration = 0.16 },
				{ id = "walk_down_5", duration = 0.16 },
			} },
			walk_up = { loop = true, frames = {
				{ id = "walk_up_0", duration = 0.16 },
				{ id = "walk_up_1", duration = 0.16 },
				{ id = "walk_up_2", duration = 0.16 },
				{ id = "walk_up_3", duration = 0.16 },
				{ id = "walk_up_4", duration = 0.16 },
				{ id = "walk_up_5", duration = 0.16 },
			} },
			walk_left = { loop = true, frames = {
				{ id = "walk_left_0", duration = 0.16 },
				{ id = "walk_left_1", duration = 0.16 },
				{ id = "walk_left_2", duration = 0.16 },
				{ id = "walk_left_3", duration = 0.16 },
				{ id = "walk_left_4", duration = 0.16 },
				{ id = "walk_left_5", duration = 0.16 },
			} },
			walk_right = { loop = true, frames = {
				{ id = "walk_right_0", duration = 0.16 },
				{ id = "walk_right_1", duration = 0.16 },
				{ id = "walk_right_2", duration = 0.16 },
				{ id = "walk_right_3", duration = 0.16 },
				{ id = "walk_right_4", duration = 0.16 },
				{ id = "walk_right_5", duration = 0.16 },
			} },
			attack_down_0 = { loop = false, frames = {
				{ id = "attack_down_0_0", duration = 0.16 },
				{ id = "attack_down_0_1", duration = 0.08 },
				{ id = "attack_down_0_2", duration = 0.08 },
				{ id = "attack_down_0_3", duration = 0.24 },
			} },
			attack_down_1 = { loop = false, frames = {
				{ id = "attack_down_1_0", duration = 0.16 },
				{ id = "attack_down_1_1", duration = 0.08 },
				{ id = "attack_down_1_2", duration = 0.08 },
				{ id = "attack_down_1_3", duration = 0.24 },
			} },
			attack_down_2 = { loop = false, frames = {
				{ id = "attack_down_2_0", duration = 0.16 },
				{ id = "attack_down_2_1", duration = 0.08 },
				{ id = "attack_down_2_2", duration = 0.08 },
				{ id = "attack_down_2_3", duration = 0.08 },
				{ id = "attack_down_3_0", duration = 0.32 },
			} },
			attack_down_3 = { loop = false, frames = {
				{ id = "attack_down_3_1", duration = 0.08 },
				{ id = "attack_down_3_2", duration = 0.08 },
				{ id = "attack_down_3_3", duration = 0.24 },
			} },
			attack_up_0 = { loop = false, frames = {
				{ id = "attack_up_0_0", duration = 0.08 },
				{ id = "attack_up_0_1", duration = 0.08 },
				{ id = "attack_up_0_2", duration = 0.08 },
				{ id = "attack_up_0_3", duration = 0.16 },
			} },
			attack_right_0 = { loop = false, frames = {
				{ id = "attack_right_0_0", duration = 0.08 },
				{ id = "attack_right_0_1", duration = 0.08 },
				{ id = "attack_right_0_2", duration = 0.08 },
				{ id = "attack_right_0_3", duration = 0.16 },
			} },
			attack_left_0 = { loop = false, frames = {
				{ id = "attack_left_0_0", duration = 0.08 },
				{ id = "attack_left_0_1", duration = 0.08 },
				{ id = "attack_left_0_2", duration = 0.08 },
				{ id = "attack_left_0_3", duration = 0.16 },
			} },
			dash_down = { loop = false, frames = {
				{ id = "attack_down_1_0", duration = 0.24 },
				{ id = "attack_down_1_1", duration = 0.08 },
				{ id = "attack_down_1_2", duration = 0.08 },
				{ id = "attack_down_1_3", duration = 0.08 },
			} },
			dash_up = { loop = false, frames = {
				{ id = "attack_up_1_0", duration = 0.24 },
				{ id = "attack_up_1_1", duration = 0.08 },
				{ id = "attack_up_1_2", duration = 0.08 },
				{ id = "attack_up_1_3", duration = 0.08 },
			} },
			dash_right = { loop = false, frames = {
				{ id = "attack_right_1_0", duration = 0.24 },
				{ id = "attack_right_1_1", duration = 0.08 },
				{ id = "attack_right_1_2", duration = 0.08 },
				{ id = "attack_right_1_3", duration = 0.08 },
			} },
			dash_left = { loop = false, frames = {
				{ id = "attack_left_1_0", duration = 0.24 },
				{ id = "attack_left_1_1", duration = 0.08 },
				{ id = "attack_left_1_2", duration = 0.08 },
				{ id = "attack_left_1_3", duration = 0.08 },
			} },
			knockback_down = { frames = { { id = "knockback_down" } } },
			knockback_up = { frames = { { id = "knockback_up" } } },
			knockback_right = { frames = { { id = "knockback_right" } } },
			knockback_left = { frames = { { id = "knockback_left" } } },
			death = { loop = false, frames = {
				{ id = "death_0", duration = 0.32 },
				{ id = "death_1", duration = 0.08 },
			} },
		},
	},
};