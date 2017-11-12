require( "src/utils/OOP" );
local TableUtils = require( "src/utils/TableUtils" );

local ScriptRunner = Class( "ScriptRunner" );



-- PUBLIC API

ScriptRunner.init = function( self, entity )
	assert( entity );
	self._entity = entity;
	self._scripts = {};
	self._newScripts = {};
end

ScriptRunner.addScript = function( self, script )
	table.insert( self._newScripts, script );
end

ScriptRunner.removeScript = function( self, script )
	for i, activeScript in ipairs( self._scripts ) do
		if activeScript == script then
			table.remove( self, i );
			return;
		end
	end
end

ScriptRunner.update = function( self, dt )
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

ScriptRunner.signal = function( self, signal, ... )
	local scriptsCopy = TableUtils.shallowCopy( self._scripts );
	for _, script in ipairs( scriptsCopy ) do
		script:signal( signal, ... );
	end
end



return ScriptRunner;
