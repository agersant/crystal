return {
	type = "spritesheet",
	content = {
		texture = "arpg/assets/texture/sprite/sahagin.png",
		frames = {
			
			frame_0 = { x = 0, y = 0, w = 26, h = 25, },
			
			frame_1 = { x = 26, y = 0, w = 23, h = 46, },
			
			frame_2 = { x = 49, y = 0, w = 23, h = 40, },
			
			frame_3 = { x = 72, y = 0, w = 26, h = 23, },
			
			frame_4 = { x = 98, y = 0, w = 49, h = 24, },
			
			frame_5 = { x = 147, y = 0, w = 38, h = 24, },
			
			frame_6 = { x = 185, y = 0, w = 26, h = 23, },
			
			frame_7 = { x = 211, y = 0, w = 49, h = 24, },
			
			frame_8 = { x = 260, y = 0, w = 38, h = 24, },
			
			frame_9 = { x = 298, y = 0, w = 24, h = 22, },
			
			frame_10 = { x = 322, y = 0, w = 23, h = 46, },
			
			frame_11 = { x = 345, y = 0, w = 23, h = 34, },
			
			frame_12 = { x = 368, y = 0, w = 27, h = 23, },
			
			frame_13 = { x = 395, y = 0, w = 22, h = 26, },
			
			frame_14 = { x = 417, y = 0, w = 22, h = 26, },
			
			frame_15 = { x = 439, y = 0, w = 28, h = 25, },
			
			frame_16 = { x = 467, y = 0, w = 34, h = 23, },
			
			frame_17 = { x = 501, y = 0, w = 42, h = 22, },
			
			frame_18 = { x = 543, y = 0, w = 24, h = 26, },
			
			frame_19 = { x = 567, y = 0, w = 33, h = 25, },
			
			frame_20 = { x = 600, y = 0, w = 28, h = 29, },
			
			frame_21 = { x = 628, y = 0, w = 28, h = 27, },
			
			frame_22 = { x = 656, y = 0, w = 28, h = 29, },
			
			frame_23 = { x = 684, y = 0, w = 28, h = 27, },
			
			frame_24 = { x = 712, y = 0, w = 22, h = 28, },
			
			frame_25 = { x = 734, y = 0, w = 32, h = 26, },
			
		},
		animations = {
			
			["attack"] = {
				loop = false,
				sequences = {
					
					{
						direction = "East",
						frames = {
							
							{ id = "frame_6", duration = 0.3, ox = 15, oy = 19,
																					tags = {
																["weak"] = { rect = { x = -9, y = -15, w = 14, h = 15 } },
															},
														},
							
							{ id = "frame_7", duration = 0.08, ox = 12, oy = 19,
																					tags = {
																["hit"] = { rect = { x = 10, y = -7, w = 24, h = 7 } },
																["weak"] = { rect = { x = -5, y = -15, w = 13, h = 16 } },
															},
														},
							
							{ id = "frame_8", duration = 0.082, ox = 12, oy = 19,
																					tags = {
																["weak"] = { rect = { x = -6, y = -16, w = 15, h = 16 } },
															},
														},
							
						},
					},
					
					{
						direction = "North",
						frames = {
							
							{ id = "frame_9", duration = 0.301, ox = 11, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -6, y = -14, w = 14, h = 14 } },
															},
														},
							
							{ id = "frame_10", duration = 0.079, ox = 12, oy = 41,
																					tags = {
																["hit"] = { rect = { x = 1, y = -38, w = 7, h = 24 } },
																["weak"] = { rect = { x = -7, y = -13, w = 16, h = 14 } },
															},
														},
							
							{ id = "frame_11", duration = 0.084, ox = 12, oy = 29,
																					tags = {
																["weak"] = { rect = { x = -6, y = -13, w = 14, h = 13 } },
															},
														},
							
						},
					},
					
					{
						direction = "West",
						frames = {
							
							{ id = "frame_3", duration = 0.302, ox = 11, oy = 19,
																					tags = {
																["weak"] = { rect = { x = -5, y = -15, w = 15, h = 15 } },
															},
														},
							
							{ id = "frame_4", duration = 0.081, ox = 37, oy = 19,
																					tags = {
																["hit"] = { rect = { x = -34, y = -7, w = 24, h = 7 } },
																["weak"] = { rect = { x = -8, y = -15, w = 14, h = 16 } },
															},
														},
							
							{ id = "frame_5", duration = 0.083, ox = 26, oy = 19,
																					tags = {
																["weak"] = { rect = { x = -8, y = -15, w = 13, h = 16 } },
															},
														},
							
						},
					},
					
					{
						direction = "South",
						frames = {
							
							{ id = "frame_0", duration = 0.301, ox = 12, oy = 21,
																					tags = {
																["weak"] = { rect = { x = -8, y = -15, w = 17, h = 16 } },
															},
														},
							
							{ id = "frame_1", duration = 0.082, ox = 12, oy = 18,
																					tags = {
																["hit"] = { rect = { x = -9, y = 1, w = 7, h = 24 } },
																["weak"] = { rect = { x = -7, y = -13, w = 16, h = 13 } },
															},
														},
							
							{ id = "frame_2", duration = 0.081, ox = 12, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -7, y = -13, w = 17, h = 13 } },
															},
														},
							
						},
					},
					
				},
			},
			
			["idle"] = {
				loop = false,
				sequences = {
					
					{
						direction = "East",
						frames = {
							
							{ id = "frame_14", duration = 0.1, ox = 12, oy = 17,
																					tags = {
																["weak"] = { rect = { x = -5, y = -14, w = 12, h = 15 } },
															},
														},
							
						},
					},
					
					{
						direction = "North",
						frames = {
							
							{ id = "frame_15", duration = 0.1, ox = 14, oy = 20,
																					tags = {
																["weak"] = { rect = { x = -7, y = -14, w = 15, h = 15 } },
															},
														},
							
						},
					},
					
					{
						direction = "West",
						frames = {
							
							{ id = "frame_13", duration = 0.1, ox = 10, oy = 17,
																					tags = {
																["weak"] = { rect = { x = -8, y = -13, w = 15, h = 14 } },
															},
														},
							
						},
					},
					
					{
						direction = "South",
						frames = {
							
							{ id = "frame_12", duration = 0.1, ox = 14, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -7, y = -13, w = 14, h = 15 } },
															},
														},
							
						},
					},
					
				},
			},
			
			["knockback"] = {
				loop = true,
				sequences = {
					
					{
						direction = "North",
						frames = {
							
							{ id = "frame_16", duration = 0.1, ox = 24, oy = 19,
																					tags = {
																["weak"] = { rect = { x = -10, y = -14, w = 17, h = 14 } },
															},
														},
							
						},
					},
					
				},
			},
			
			["smashed"] = {
				loop = true,
				sequences = {
					
					{
						direction = "North",
						frames = {
							
							{ id = "frame_17", duration = 0.1, ox = 26, oy = 9,
																					},
							
						},
					},
					
				},
			},
			
			["walk"] = {
				loop = true,
				sequences = {
					
					{
						direction = "East",
						frames = {
							
							{ id = "frame_23", duration = 0.15, ox = 17, oy = 18,
																					},
							
							{ id = "frame_14", duration = 0.15, ox = 12, oy = 17,
																					},
							
							{ id = "frame_22", duration = 0.15, ox = 12, oy = 18,
																					},
							
							{ id = "frame_14", duration = 0.15, ox = 12, oy = 17,
																					},
							
						},
					},
					
					{
						direction = "North",
						frames = {
							
							{ id = "frame_24", duration = 0.15, ox = 12, oy = 20,
																					},
							
							{ id = "frame_15", duration = 0.15, ox = 14, oy = 21,
																					},
							
							{ id = "frame_25", duration = 0.15, ox = 10, oy = 18,
																					},
							
							{ id = "frame_15", duration = 0.15, ox = 14, oy = 21,
																					},
							
						},
					},
					
					{
						direction = "West",
						frames = {
							
							{ id = "frame_21", duration = 0.15, ox = 11, oy = 18,
																					},
							
							{ id = "frame_13", duration = 0.15, ox = 10, oy = 17,
																					},
							
							{ id = "frame_20", duration = 0.15, ox = 16, oy = 18,
																					},
							
							{ id = "frame_13", duration = 0.15, ox = 10, oy = 17,
																					},
							
						},
					},
					
					{
						direction = "South",
						frames = {
							
							{ id = "frame_18", duration = 0.15, ox = 11, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -7, y = -13, w = 15, h = 15 } },
															},
														},
							
							{ id = "frame_12", duration = 0.15, ox = 14, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -7, y = -13, w = 14, h = 15 } },
															},
														},
							
							{ id = "frame_19", duration = 0.15, ox = 22, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -8, y = -14, w = 15, h = 16 } },
															},
														},
							
							{ id = "frame_12", duration = 0.15, ox = 14, oy = 18,
																					tags = {
																["weak"] = { rect = { x = -7, y = -13, w = 14, h = 15 } },
															},
														},
							
						},
					},
					
				},
			},
			
		},
	},
};
