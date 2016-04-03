require( "src/utils/OOP" );
local Script = require( "src/scene/controller/Script" );

local Controller = Class( "Controller" );



-- PUBLIC API

Controller.init = function( self, entity )
	assert( entity );
	self._entity = entity;
	self._scripts = {};
	self._newScripts = {};
end

Controller.getEntity = function( self )
	return self._entity;
end

Controller.addScript = function( self, script )
	table.insert( self._newScripts, script );
	script:update( 0 );
end

Controller.removeScript = function( self, script )
	for i, activeScript in ipairs( self._scripts ) do
		if activeScript == script then
			table.remove( self, i );
			return;
		end
	end
end

Controller.update = function( self, dt )
	for i, newScript in ipairs( self._newScripts ) do
		table.insert( self._scripts, newScript );
	end
	self._newScripts = {};
	
	for i, script in ipairs( self._scripts ) do
		script:update( dt );
	end
	
	for i = #self._scripts, 1, -1 do
		local script = self._scripts[i];
		if script:isDead() then
			table.remove( self._scripts, i );
		end
	end
end

Controller.signal = function( self, signal, ... )
	for i, script in ipairs( self._scripts ) do
		script:signal( signal, ... );
	end
end

Controller.isIdle = function( self )
	return not self._actionScript or self._actionScript:isDead();
end

Controller.doAction = function( self, actionFunction )
	assert( self:isIdle() );
	self._actionScript = Script:new( self:getEntity(), actionFunction );
	self:addScript( self._actionScript );
end

Controller.isTaskless = function( self )
	return not self._taskScript or self._taskScript:isDead();
end

Controller.doTask = function( self, taskFunction )
	assert( self:isTaskless() );
	self._taskScript = Script:new( self:getEntity(), taskFunction );
	self:addScript( self._taskScript );
end



return Controller;
