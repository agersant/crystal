local realAPI = love.graphics;
local mockAPI = {};

local noop = function()
end

local spriteBatch = {add = noop};

local font = {
	getHeight = function()
		return 1;
	end,
	getWidth = function()
		return 1;
	end,
	setFilter = noop,
};

local image = {
	setFilter = noop,
	getDimensions = function()
		return 1, 1;
	end,
};

local quad = {
	setViewport = noop,
	getViewport = function()
		return 0, 0, 1, 1;
	end,
};

mockAPI.getWidth = function()
	return 1;
end

mockAPI.getHeight = function()
	return 1;
end

mockAPI.newFont = function()
	return font;
end

mockAPI.newImage = function()
	return image;
end

mockAPI.newSpriteBatch = function()
	return spriteBatch;
end

mockAPI.newQuad = function()
	return quad;
end

mockAPI.polygon = noop;

mockAPI.print = noop;

mockAPI.rectangle = noop;

mockAPI.setColor = noop;

mockAPI.setFont = noop;

local Mocking = {};

Mocking.enable = function(self)
	love.graphics = mockAPI;
end

Mocking.disable = function(self)
	love.graphics = realAPI;
end

return Mocking;
