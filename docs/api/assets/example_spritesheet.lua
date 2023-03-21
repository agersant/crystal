-- All numbers and `ALL_CAPS` words are placeholder to be replaced with your actual content.

return {
	crystal_spritesheet = true,
	texture = "PATH/TO/TEXTURE.png",
	frames = {
		FRAME_0 = { x = 0, y = 0, w = 32, h = 32, },
		FRAME_1 = { x = 32, y = 0, w = 32, h = 32, },
		-- etc. (more frames)
	},
	animations = {
		IDLE = {
			loop = true,
			sequences = {
				{
					direction = "West", -- Supported values: East, NorthEast, North, NorthWest, West, SouthWest, South, SouthEast
					keyframes = {
						{
							frame = "FRAME_0",
							duration = 0.1,
							x = 0.0,
							y = 0.0,
							hitboxes = {
								["HITBOX"] = { rect = { x = -8, y = -8, w = 16, h = 16 } },
								["OTHER_HITBOX"] = { rect = { x = -12, y = -6, w = 11, h = 11 } },
							},
						},
						{
							frame = "FRAME_1",
							duration = 0.1,
							x = 0.0,
							y = -2.0,
							hitboxes = {
								["HITBOX"] = { rect = { x = -8, y = -8, w = 16, h = 16 } },
							},
						},
					},
				},
				-- etc. (more sequences for the IDLE animation)
			},
		},
		-- etc. (more animations)
	},
}
