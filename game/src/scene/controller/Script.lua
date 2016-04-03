require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local TableUtils = require( "src/utils/TableUtils" );

local Script = Class( "Script" );



-- IMPLEMENTATION

local pumpThread, endThread;

local newThread = function( self, parentThread, script, options )
	assert( type( script ) == "function" );
	local threadCoroutine = coroutine.create( script );
	
	-- TODO wrap in a class
	local thread = {
		coroutine = threadCoroutine,
		childThreads = {},
		blockedBy = {},
		endsOn = {},
		isDead = function( thread )
			return coroutine.status( thread.coroutine ) == "dead" or thread.isEnded;
		end,
		stop = function( thread )
			assert( not thread:isDead() );
			endThread( self, thread );
		end,
	};
	
	if parentThread then
		parentThread.childThreads[thread] = true;
		thread.parentThread = parentThread;
	end
	
	if options.pumpImmediately then
		pumpThread( self, thread );
	end
	
	table.insert( self._newThreads, thread );
	return thread;
end

local blockThread = function( self, thread, signals )
	thread.isBlocked = true;
	thread.isMarkedForUnblock = false;
	for _, signal in ipairs( signals ) do
		assert( type( signal ) == "string" );
		if not self._blockedThreads[signal] then
			self._blockedThreads[signal] = {};
		end
		self._blockedThreads[signal][thread] = true;
		thread.blockedBy[signal] = true;
	end
end

local unblockThread = function( self, thread, signal, ... )
	assert( thread.isBlocked );
	for signal, _ in pairs( thread.blockedBy ) do
		self._blockedThreads[signal][thread] = nil;
	end
	local signalData = { ... };
	if TableUtils.countKeys( thread.blockedBy ) > 1 then
		table.insert( signalData, 1, signal );
	end
	thread.isMarkedForUnblock = true;
	pumpThread( self, thread, signalData );
end

local endThreadOn = function( self, thread, signals )
	for _, signal in ipairs( signals ) do
		assert( type( signal ) == "string" );
		if not self._endableThreads[signal] then
			self._endableThreads[signal] = {};
		end
		self._endableThreads[signal][thread] = true;
		thread.endsOn[signal] = true;
	end
end

endThread = function( self, thread )
	thread.isEnded = true;
	if thread.parentThread then
		thread.parentThread.childThreads[thread] = nil;
		thread.parentThread = nil;
	end
	local childThreadsCopy = {};
	for childThread, _  in pairs( thread.childThreads ) do
		table.insert( childThreadsCopy, childThread );
	end
	for i, childThread  in ipairs( childThreadsCopy ) do
		endThread( self, childThread );
	end
end

pumpThread = function( self, thread, resumeArgs )
	local status = coroutine.status( thread.coroutine );
	assert( status ~= "running" );
	if status == "suspended" and not thread.isEnded then
		local success, a, b;
		if resumeArgs then
			success, a, b = coroutine.resume( thread.coroutine, resumeArgs );
		else
			success, a, b = coroutine.resume( thread.coroutine, self );
		end
		if not success then
			Log:error( a );
		elseif a == "fork" then
			local childThread = newThread( self, thread, b, { pumpImmediately = true } );
			pumpThread( self, thread, childThread );
		elseif a == "waitForSignals" then
			blockThread( self, thread, b );
		elseif a == "endOnSignals" then
			endThreadOn( self, thread, b );
			pumpThread( self, thread );
		end
	end
	
	status = coroutine.status( thread.coroutine );
	if status == "dead" and not thread.isEnded then
		endThread( self, thread );
	end
end

local cleanupThread = function( self, thread )
	if thread.endsOn then
		for signal, _ in pairs( thread.endsOn ) do
			self._endableThreads[signal][thread] = nil;
		end
	end
	for signal, _ in pairs( thread.blockedBy ) do
		self._blockedThreads[signal][thread] = nil;
	end
	for childThread, _  in pairs( thread.childThreads ) do
		childThread.parentThread = nil;
	end
	if thread == self._actionThread then
		self._actionThread = nil;
	end
	if thread == self._taskThread then
		self._taskThread = nil;
	end
end



-- PUBLIC API

Script.init = function( self, controller, scriptFunction )
	assert( controller );
	assert( type( scriptFunction ) == "function" );
	self._controller = controller;
	self._time = 0;
	self._dt = 0;
	self._threads = {};
	self._newThreads = {};
	self._blockedThreads = {};
	self._endableThreads = {};
	self._queuedSignals = {};
	newThread( self, nil, scriptFunction, { pumpImmediately = false } );
end

Script.getController = function( self )
	return self._controller;
end

Script.update = function( self, dt )
	
	-- Process queued signals
	for _, signalData in ipairs( self._queuedSignals ) do
		self:signal( signalData.name, unpack( signalData.userData ) );
	end
	self._queuedSignals = {};
	
	self._time = self._time + dt;
	self._dt = dt;
	
	-- Add new threads
	for _, newThread in ipairs( self._newThreads ) do
		table.insert( self._threads, newThread );
	end
	self._newThreads = {};
	
	-- Run existing threads
	for _, thread in ipairs( self._threads ) do
		if not thread.isBlocked then
			pumpThread( self, thread );
		end
	end
	
	-- Remove dead threads
	for i = #self._threads, 1, -1 do
		local thread = self._threads[i];
		if thread:isDead() then
			cleanupThread( self, thread );
			table.remove( self._threads, i );
		end
	end
	
	-- Unblock threads. We don't want to do this from inside the "run threads" loop above to avoid a thread being pumped twice (once in unblockThread, once in the loop above).
	for _, thread in ipairs( self._threads ) do
		if thread.isBlocked and thread.isMarkedForUnblock then
			thread.blockedBy = {};
			thread.isBlocked = false;
			thread.isMarkedForUnblock = false;
		end
	end
end

Script.signal = function( self, signal, ... )
	if not self._controller:getEntity():getScene():canProcessSignals() then
		table.insert( self._queuedSignals, { name = signal, userData = { ... } } );
		return;
	end
	if self._endableThreads[signal] then
		for thread, _ in pairs( self._endableThreads[signal] ) do
			endThread( self, thread, signal );
		end
	end
	if self._blockedThreads[signal] then
		for thread, _ in pairs( self._blockedThreads[signal] ) do
			unblockThread( self, thread, signal, ... );
		end
	end
end

Script.waitFrame = function( self )
	coroutine.yield();
end

Script.wait = function( self, seconds )
	local endTime = self._time + seconds;
	while self._time < endTime do
		coroutine.yield();
	end
end

Script.thread = function( self, script )
	assert( type( script ) == "function" );
	return coroutine.yield( "fork", script );
end

Script.waitFor = function( self, signal )
	assert( type( signal ) == "string" );
	return self:waitForAny( { signal } );
end

Script.waitForAny = function( self, signals )
	assert( type( signals ) == "table" );
	local returns = coroutine.yield( "waitForSignals", signals );
	return unpack( returns );
end

Script.waitForCommandPress = function( self, command )
	while true do
		local inputDevice = self:getController():getInputDevice();
		if inputDevice and not inputDevice:isCommandActive( command ) then
			break;
		else
			self:waitFrame();
		end
	end
	self:waitFor( "+" .. command );
end

Script.endOn = function( self, signal )
	assert( type( signal ) == "string" );
	return self:endOnAny( { signal } );
end

Script.endOnAny = function( self, signals )
	assert( type( signals ) == "table" );
	coroutine.yield( "endOnSignals", signals );
end

Script.isDead = function( self )
	return #self._threads == 0 and #self._newThreads == 0;
end



return Script;
