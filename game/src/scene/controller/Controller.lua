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

local endThreadOn = function( self, thread, signals )
	for _, signal in ipairs( signals ) do
		assert( type( signal ) == "string" );
		if not self._endableThreads[signal] then
			self._endableThreads[signal] = {};
		end
		self._endableThreads[signal][thread] = true;
	end
end

local endThread = function( self, thread )
	thread.isEnded = true;
	if thread.blockedBy then
		for _, signal in ipairs( thread.blockedBy ) do
			self._blockedThreads[signal][thread] = nil;
		end
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
		elseif a == "waitForSignals" then
			blockThread( self, thread, b );
		elseif a == "endOnSignals" then
			endThreadOn( self, thread, b );
			pumpThread( self, thread );
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
	self._endableThreads = {};
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
		if thread.isEnded or coroutine.status( thread.coroutine ) == "dead" then
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
	if self._endableThreads[signal] then
		for thread, _ in pairs( self._endableThreads[signal] ) do
			endThread( self, thread, signal );
			self._endableThreads[signal][thread] = nil;
		end
	end
	if self._blockedThreads[signal] then
		for thread, _ in pairs( self._blockedThreads[signal] ) do
			unblockThread( self, thread, signal, ... );
		end
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
	thread.isDead = function( self )
		return coroutine.status( self.coroutine ) == "dead" or self.isEnded;
	end
	
	if pumpImmediately ~= false then
		pumpThread( self, thread );
	end
	table.insert( self._newThreads, thread );
	return thread;
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

Controller.endOn = function( self, signal )
	assert( type( signal ) == "string" );
	return self:endOnAny( { signal } );
end

Controller.endOnAny = function( self, signals )
	assert( type( signals ) == "table" );
	coroutine.yield( "endOnSignals", signals );
end

Controller.isIdle = function( self )
	return not self._stateThread or self._stateThread:isDead();
end

Controller.enterState = function( self, stateFunction )
	assert( self:isIdle() );
	self._stateThread = self:thread( function( self )
		stateFunction( self );
	end );
end


return Controller;
