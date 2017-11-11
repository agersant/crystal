require( "src/utils/OOP" );

local GFXConfig = Class( "GFXConfig" );
local instance;



-- IMPLEMENTATION

local setMode = function( self )
	if not love.window then
		return;
	end
	love.window.setMode( self._windowWidth, self._windowHeight, {
		msaa = 8,
		resizable = true,
		vsync = false,
		fullscreen = self._fullscreen,
	} );
	love.window.setTitle( "Crystal" );
end

local refreshZoom = function( self )
	local zx = self._windowWidth / self._renderWidth;
	local zy = self._windowHeight / self._renderHeight;
	self._zoom = math.max( 1, math.min( math.floor( zx ), math.floor( zy ) ) );
end



-- PUBLIC API

love.resize = function( width, height )
	instance._windowWidth = width;
	instance._windowHeight = height;
	refreshZoom( instance );
end

GFXConfig.init = function( self )

	-- How content is authored
	self._nativeWidth = 480;
	self._nativeHeight = 272;

	-- Base resolution
	self._renderWidth = 480;
	self._renderHeight = 270;

	self._zoom = 1;

	self:setZoom( 2 );
end

GFXConfig.setResolution = function( self, width, height )
	self._windowWidth = width;
	self._windowHeight = height;
	refreshZoom( self );
	setMode( self );
end

GFXConfig.setFullscreenEnabled = function( self, enabled )
	self._fullscreen = enabled;
	setMode( self );
end

GFXConfig.setZoom = function( self, zoom )
	assert( zoom > 0 );
	assert( zoom == math.floor( zoom ) );
	self:setResolution( self._renderWidth * zoom, self._renderHeight * zoom );
end

GFXConfig.getZoom = function( self )
	return self._zoom;
end

GFXConfig.getNativeSize = function( self )
	return self._nativeWidth, self._nativeHeight;
end

GFXConfig.applyTransforms = function( self )

	-- Letterbox
	local w = self._renderWidth * self._zoom;
	local h = self._renderHeight * self._zoom;
	local letterBoxDx = math.floor( ( self._windowWidth - self._renderWidth * self._zoom ) / 2 );
	local letterBoxDy = math.floor( ( self._windowHeight - self._renderHeight * self._zoom ) / 2 );
	love.graphics.setScissor( letterBoxDx, letterBoxDy, w, h );
	love.graphics.translate( letterBoxDx, letterBoxDy );

	-- Center native size within render size
	love.graphics.translate(
		( self._renderWidth - self._nativeWidth ) / 2,
		( self._renderHeight - self._nativeHeight ) / 2
	);

	-- Zoom
	love.graphics.scale( self._zoom, self._zoom );

end


instance = GFXConfig:new();
return instance;
