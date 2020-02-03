_G["love"] = love or {};
love.graphics = {};

local noop = function()
end

local image = {
	setFilter = noop,
	getDimensions = function()
		return 1, 1;
	end,
};

local font = {setFilter = noop};

love.graphics.newFont = function()
	return font;
end
love.graphics.newImage = function()
	return image;
end
love.graphics.newSpriteBatch = noop;
love.graphics.newQuad = noop;
love.graphics.getWidth = function()
	return 1;
end
love.graphics.getHeight = function()
	return 1;
end
