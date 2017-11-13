require( "src/utils/OOP" );
local Script = require( "src/scene/Script" );

local Controller = Class( "Controller", Script );



-- PUBLIC API

Controller.init = function( self, entity, scriptContent )
	assert( entity );
	self._entity = entity;
	Controller.super.init( self, scriptContent );
end

Controller.getEntity = function( self )
	return self._entity;
end

Controller.isIdle = function( self )
	return not self._actionThread or self._actionThread:isDead();
end

Controller.doAction = function( self, actionFunction )
	assert( self:isIdle() );
	self._actionThread = self:thread( function( self )
		actionFunction( self );
		self._actionThread = nil;
		self:getEntity():signal( "idle" );
	end );
end

Controller.stopAction = function( self )
	self._actionThread = nil;
end

Controller.isTaskless = function( self )
	return not self._taskThread or self._taskThread:isDead();
end

Controller.doTask = function( self, taskFunction )
	assert( self:isTaskless() );
	self._taskThread = self:thread( taskFunction );
end

Controller.stopTask = function( self )
	self._taskThread = nil;
end



return Controller;
