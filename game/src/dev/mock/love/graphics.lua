love = love or {};
love.graphics = {};

local void = function() end;

love.graphics.newFont = void;

local image = {
	setFilter = void,
	getDimensions = function() return 1, 1; end,
};

love.graphics.newImage = function() return image; end
love.graphics.newSpriteBatch = void;
love.graphics.newQuad = void;
love.graphics.getWidth = function() return 1; end
love.graphics.getHeight = function() return 1; end