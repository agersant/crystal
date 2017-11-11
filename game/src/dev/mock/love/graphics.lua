love = love or {};
love.graphics = {};

local void = function() end;

local image = {
	setFilter = void,
	getDimensions = function() return 1, 1; end,
};

local font = {
	setFilter = void,
};

love.graphics.newFont = function() return font; end
love.graphics.newImage = function() return image; end
love.graphics.newSpriteBatch = void;
love.graphics.newQuad = void;
love.graphics.getWidth = function() return 1; end
love.graphics.getHeight = function() return 1; end