require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );

local Controller = Class( "Controller" );



-- IMPLEMENTATION

local pumpThread;

local blockThread = function( self, thread, signals )
	thread.isBlocked = true;
	thread.isMarkedForUnblock = false;
	thread.blockedBy = signals;
	for _, signal in ipairs( signals ) do
		assert( type( signal ) == "string" );
		if not self._blockedThreads[signal] then
			self._blockedThreads[signal] = {};
		end
		self._blockedThreads[signal][thread] = true;
	end
end

local unblockThread = function( self, thread, signal, ... )
	assert( thread.isBlocked );
	for _, signal in ipairs( thread.blockedBy ) do
		self._blockedThreads[signal][thread] = nil;
	end
	local signalData = { ... };
	if #thread.blockedBy > 1 then
		table.insert( signalData, 1, signal );
	end
	thread.isMarkedForUnblock = true;
	pumpThread( self, thread, signalData );
end

pumpThread = function( self, thread, resumeArgs )
	local status = coroutine.status( thread.coroutine );
	assert( status ~= "running" );
	if status == "suspended" then
		local success, a, b;
		if resumeArgs then
			success, a, b = coroutine.resume( thread.coroutine, resumeArgs );
		else
			success, a, b = coroutine.resume( thread.coroutine, self, self._entity );
		end
		if not success then
			Log:error( a );
		elseif a == "waitForSignals" then
			blockThread( self, thread, b );
		end
	end
end



-- PUBLIC API

Controller.init = function( self, entity, script )
	assert( entity );
	self._entity = entity;
	self._time = 0;
	self._threads = {};
	self._newThreads = {};
	self._blockedThreads = {};
	self._queuedSignals = {};
	self:thread( script, false );
end

Controller.getEntity = function( self )
	return self._entity;
end

Controller.update = function( self, dt )
	
	-- Process queued signals
	for _, signalData in ipairs( self._queuedSignals ) do
		self:signal( signalData.name, unpack( signalData.userData ) );
	end
	self._queuedSignals = {};
	
	self._time = self._time + dt;
	
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
		if coroutine.status( thread.coroutine ) == "dead" then
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

Controller.signal = function( self, signal, ... )
	if not self._entity:getScene():canProcessSignals() then
		table.insert( self._queuedSignals, { name = signal, userData = { ... } } );
		return;
	end
	if not self._blockedThreads[signal] then
		return;
	end
	for thread, _ in pairs( self._blockedThreads[signal] ) do
		unblockThread( self, thread, signal, ... );
	end
end

Controller.waitFrame = function( self )
	coroutine.yield();
end

Controller.wait = function( self, seconds )
	local endTime = self._time + seconds;
	while self._time < endTime do
		coroutine.yield();
	end
end

Controller.thread = function( self, script, pumpImmediately )
	assert( type( script ) == "function" );
	local threadCoroutine = coroutine.create( script );
	local thread = { coroutine = threadCoroutine };
	if pumpImmediately ~= false then
		pumpThread( self, thread );
	end
	table.insert( self._newThreads, thread );
end

Controller.waitFor = function( self, signal )
	assert( type( signal ) == "string" );
	return self:waitForAny( { signal } );
end

Controller.waitForAny = function( self, signals )
	assert( type( signals ) == "table" );
	local returns = coroutine.yield( "waitForSignals", signals );
	return unpack( returns );
end



return Controller;
