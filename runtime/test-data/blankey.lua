return {
	type = "spritesheet",
	content = {
		texture = "test-data/blankey.png",
		frames = {
			frame_0 = { x = 0, y = 0, w = 32, h = 32, },
			frame_1 = { x = 32, y = 0, w = 32, h = 32, },
			frame_2 = { x = 64, y = 0, w = 32, h = 32, },
			frame_3 = { x = 96, y = 0, w = 32, h = 32, },
			frame_4 = { x = 128, y = 0, w = 32, h = 32, },
		},
		animations = {
			["floating"] = {
				loop = true,
				sequences = {
					{
						direction = "North",
						frames = {
							{
								id = "frame_0", duration = 0.302, ox = 16.0, oy = 16.0,
							},
							{
								id = "frame_1", duration = 0.299, ox = 16.0, oy = 16.0,
							},
							{
								id = "frame_2", duration = 0.299, ox = 16.0, oy = 16.0,
							},
							{
								id = "frame_3", duration = 0.302, ox = 16.0, oy = 16.0,
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
						frames = {
							{
								id = "frame_4", duration = 0.1, ox = 16.0, oy = 16.0,
								tags = {
									["test"] = { rect = { x = -5, y = -6, w = 11, h = 11 } },
								},
							},
						},
					},
				},
			},
		},
	},
};
