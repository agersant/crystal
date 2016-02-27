require( "src/utils/OOP" );

local InputDevice = Class( "InputDevice" );


-- IMPLEMENTATION

local buildReverseBindings = function( self )
	self._reverseBindings = {};
	for command, binding in pairs( self._bindings ) do
		assert( command == binding.command );
		for i, key in ipairs( binding.keys ) do
			if not self._reverseBindings[key] then
				self._reverseBindings[key] = { commands = {} };
			end
			table.insert( self._reverseBindings[key].commands, command );
		end
	end
end



-- PUBLIC API

InputDevice.init = function( self )
	self._bindings = {};
	self._events = {};
	buildReverseBindings( self );
end

InputDevice.addBinding = function( self, command, key )
	assert( type( command ) == "string" );
	assert( type( key ) == "string" );
	local binding = self._bindings[command];
	if not binding then
		binding = {};
		binding.command = command;
		binding.keys = {};
		binding.numInputsDown = 0;
		self._bindings[command] = binding;
	end
	table.insert( binding.keys, key );
	buildReverseBindings( self );
end

InputDevice.clearBindingsForCommand = function( self, command )
	self._bindings[command] = nil;
	buildReverseBindings( self );
end

InputDevice.keyPressed = function( self, key, scanCode, isRepeat )
	if isRepeat then
		return;
	end
	if not self._reverseBindings[key] then
		return;
	end
	for i, command in ipairs( self._reverseBindings[key].commands ) do
		assert( self._bindings[command] );
		self._bindings[command].numInputsDown = self._bindings[command].numInputsDown + 1;
		if self._bindings[command].numInputsDown == 1 then
			table.insert( self._events, "+" .. command );
		end
	end
end

InputDevice.keyReleased = function( self, key, scanCode )
	if not self._reverseBindings[key] then
		return;
	end
	for i, command in ipairs( self._reverseBindings[key].commands ) do
		assert( self._bindings[command] );
		assert( self._bindings[command].numInputsDown > 0 );
		self._bindings[command].numInputsDown = self._bindings[command].numInputsDown - 1;
		assert( self._bindings[command].numInputsDown >= 0 );
		if self._bindings[command].numInputsDown == 0 then
			table.insert( self._events, "-" .. command );
		end
	end
end

InputDevice.isCommandActive = function( self, command )
	if not self._bindings[command] then
		return false;
	end
	return self._bindings[command].numInputsDown > 0;
end

InputDevice.pollEvents = function( self )
	return ipairs( self._events );
end

InputDevice.flushEvents = function( self )
	self._events = {};
end

return InputDevice;
