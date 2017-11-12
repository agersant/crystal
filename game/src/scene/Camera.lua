require( "src/utils/OOP" );
local GFXConfig = require( "src/graphics/GFXConfig" );
local MathUtils = require( "src/utils/MathUtils" );
local TableUtils = require( "src/utils/TableUtils" );

local Camera = Class( "Camera" );



-- IMPLEMENTATION

local epsilon = 0.001;

local computeAveragePosition = function( self )
	local tx, ty = 0, 0;
	for _, entity in ipairs( self._trackedEntities ) do
		local x, y = entity:getPosition();
		tx = tx + x;
		ty = ty + y;
	end
	tx = tx / #self._trackedEntities;
	ty = ty / #self._trackedEntities;
	return tx, ty;
end

local computeAverageVelocity = function( self )
	local vx, vy = 0, 0;
	for _, trackedEntity in ipairs( self._trackedEntities ) do
		local evx, evy = trackedEntity:getVelocity();
		vx = vx + evx;
		vy = vy + evy;
	end
	vx = vx / #self._trackedEntities;
	vy = vy / #self._trackedEntities;
	return vx, vy;
end

local computeLookAheadPosition = function( self, screenW, screenH )
	local tx, ty;
	local trackedEntity = self._trackedEntities[1];
	assert( trackedEntity );
	local ex, ey = trackedEntity:getPosition();
	local angle = trackedEntity:getAngle();
	local vx, vy = math.cos( angle ), math.sin( angle );
	if math.abs( vx ) <= epsilon then
		tx = ex;
	else
		local sign = vx / math.abs( vx );
		tx = ex + self._lookAhead * screenW * sign;
	end
	if math.abs( vy ) <= epsilon then
		ty = ey;
	else
		local sign = vy / math.abs( vy );
		ty = ey + self._lookAhead * screenH * sign;
	end
	return tx, ty;
end

local clampPosition = function( self, tx, ty, screenW, screenH )
	if self._mapWidth <= screenW then
		tx = self._mapWidth / 2;
	else
		tx = MathUtils.clamp( screenW / 2, tx, self._mapWidth - screenW / 2 );
	end
	if self._mapHeight <= screenH then
		ty = self._mapHeight / 2;
	else
		ty = MathUtils.clamp( screenH / 2, ty, self._mapHeight - screenH / 2 );
	end
	return tx, ty;
end

local computeTargetPosition = function( self )
	local tx, ty;
	local screenW, screenH = GFXConfig:getNativeSize();

	if #self._trackedEntities == 0 then
		tx = self._mapWidth / 2;
		ty = self._mapHeight / 2;
	-- TODO These cases will error when tracking entities that despawn
	elseif #self._trackedEntities > 1 then
		tx, ty = computeAveragePosition( self );
	else
		tx, ty = computeLookAheadPosition( self, screenW, screenH );
	end

	tx, ty = clampPosition( self, tx, ty, screenW, screenH );

	return tx, ty;
end



-- PUBLIC API

Camera.init = function( self, mapWidth, mapHeight )
	self:setAutopilotEnabled( true );
	self:setPosition( 0, 0 );
	self._mapWidth = mapWidth;
	self._mapHeight = mapHeight;
	self._trackedEntities = {};
	self._speed = 60;
	self._lookAhead = 0.05; -- Relative to screen size
end

Camera.snap = function( self )
	if self._auto then
		local tx, ty = computeTargetPosition( self );
		self:setPosition( tx, ty );
	end
end

Camera.addTrackedEntity = function( self, entity )
	assert( not TableUtils.contains( self._trackedEntities, entity ) );
	table.insert( self._trackedEntities, entity );
end

Camera.removeTrackedEntity = function( self, entity )
	assert( TableUtils.contains( self._trackedEntities, entity ) );
	for i, trackedEntity in ipairs( self._trackedEntities ) do
		if entity == trackedEntity then
			table.remove( self._trackedEntities, i );
			return;
		end
	end
end

Camera.setAutopilotEnabled = function( self, enabled )
	self._auto = enabled;
end

Camera.getRenderOffset = function( self )
	local left, top = self._x, self._y;
	local z = GFXConfig:getZoom();
	local screenW, screenH = GFXConfig:getNativeSize();
	left = left - screenW / 2;
	top = top - screenH / 2;
	left = MathUtils.roundTo( left, 1 / z );
	top = MathUtils.roundTo( top, 1 / z );
	return -left, -top;
end

Camera.setPosition = function( self, x, y )
	assert( type( x ) == "number" );
	assert( type( y ) == "number" );
	self._x = x;
	self._y = y;
end

Camera.getRelativePosition = function( self, worldX, worldY )
	local screenW, screenH = GFXConfig:getNativeSize();
	local screenX = worldX - self._x + screenW / 2;
	local screenY = worldY - self._y + screenH / 2;
	return screenX, screenY;
end

Camera.update = function( self, dt )

	if not self._auto then
		return;
	end

	local z = GFXConfig:getZoom();
	if z ~= self._previousZoom then
		self:snap();
		self._previousZoom = z;
		return;
	end

	local tx, ty = computeTargetPosition( self );
	local dx, dy = tx - self._x, ty - self._y;
	if dx == 0 and dy == 0 then
		return;
	end

	if #self._trackedEntities == 0 then
		self._x = tx;
		self._y = ty;
		return;
	end

	local vx, vy = computeAverageVelocity( self );

	if math.abs( vx ) > epsilon and dx ~= 0 then
		vx = ( dx / math.abs( dx ) ) * ( math.abs( vx ) + self._speed );
		local newX = self._x + dt * vx;
		if ( self._x - tx ) * ( newX - tx ) <= 0 then
			self._x = tx;
		else
			self._x = newX;
		end
	end

	if math.abs( vy ) > epsilon and dy ~= 0 then
		vy = ( dy / math.abs( dy ) ) * ( math.abs( vy ) + self._speed );
		local newY = self._y + dt * vy;
		if ( self._y - ty ) * ( newY - ty ) <= 0 then
			self._y = ty;
		else
			self._y = newY;
		end
	end
end



return Camera;
