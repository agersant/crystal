crystal.assets.add_loader("png", {
	load = function(path)
		return love.graphics.newImage(path);
	end,
});
