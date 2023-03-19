crystal.assets.add_loader("png", {
	load = function(path)
		local image = love.graphics.newImage(path);
		image:setFilter("nearest");
		return image;
	end,
});
