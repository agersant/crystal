return {
	crystal_spritesheet = true,
	texture = "test-data/blankey.png",
	frames = {
		frame_0 = { x = 64, y = 0, w = 32, h = 32, },
		frame_1 = { x = 32, y = 32, w = 32, h = 32, },
		frame_2 = { x = 32, y = 0, w = 32, h = 32, },
		frame_3 = { x = 0, y = 32, w = 32, h = 32, },
		frame_4 = { x = 0, y = 0, w = 32, h = 32, },
	},
	animations = {
		["floating"] = {
			loop = true,
			sequences = {
				{
					direction = "North",
					keyframes = {
						{
							frame = "frame_0", duration = 0.302, x = -16, y = -16,
						},
						{
							frame = "frame_1", duration = 0.299, x = -16, y = -16,
						},
						{
							frame = "frame_2", duration = 0.299, x = -16, y = -16,
						},
						{
							frame = "frame_3", duration = 0.302, x = -16, y = -16,
						},
					},
				},
			},
		},
		["hurt"] = {
			loop = false,
			sequences = {
				{
					direction = "North",
					keyframes = {
						{
							frame = "frame_4", duration = 0.1, x = -16, y = -16,
							hitboxes = {
								["test"] = { rect = { x = -5, y = -6, w = 11, h = 11 } },
							},
						},
					},
				},
			},
		},
	},
};
