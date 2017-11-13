require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local MathUtils = require( "src/utils/MathUtils" );
local TableUtils = require( "src/utils/TableUtils" );

local Script = Class( "Script" );



-- IMPLEMENTATION

local pumpThread, endThread;

local newThread = function( self, parentThread, script, options )
	assert( type( script ) == "function" );
	local threadCoroutine = coroutine.create( script );

	local thread = {
		coroutine = threadCoroutine,
		childThreads = {},
		blockedBy = {},
		endsOn = {},
		allowOrphans = options.allowOrphans,
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

	table.insert( self._threads, thread );
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
	thread.blockedBy = {};
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
	if not thread.allowOrphans then
		local childThreadsCopy = {};
		for childThread, _  in pairs( thread.childThreads ) do
			table.insert( childThreadsCopy, childThread );
		end
		for i, childThread  in ipairs( childThreadsCopy ) do
			endThread( self, childThread );
		end
	end
end

pumpThread = function( self, thread, resumeArgs )
	local status = coroutine.status( thread.coroutine );
	assert( status ~= "running" );
	if status == "suspended" and not thread.isEnded then
		local success, a, b, c;
		if resumeArgs then
			success, a, b, c = coroutine.resume( thread.coroutine, resumeArgs );
		else
			success, a, b, c = coroutine.resume( thread.coroutine, self );
		end
		if not success then
			Log:error( a );
		elseif a == "fork" then
			local parentScript = b;
			local functionToThread = c;
			local parentThread = parentScript == self and thread or nil;
			local childThread = newThread( parentScript, parentThread, functionToThread, { pumpImmediately = true, allowOrphans = false, } );
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

Script.init = function( self, scriptFunction )
	self._time = 0;
	self._dt = 0;
	self._threads = {};
	self._blockedThreads = {};
	self._endableThreads = {};
	if scriptFunction then
		assert( type( scriptFunction ) == "function" );
		newThread( self, nil, scriptFunction, { pumpImmediately = false, allowOrphans = true, } );
	end
end

Script.update = function( self, dt )

	self._time = self._time + dt;
	self._dt = dt;

	-- Run existing threads
	local threadsCopy = TableUtils.shallowCopy( self._threads );
	for _, thread in ipairs( threadsCopy ) do
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
			thread.isBlocked = false;
			thread.isMarkedForUnblock = false;
		end
	end
end

Script.signal = function( self, signal, ... )
	if self._endableThreads[signal] then
		for thread, _ in pairs( self._endableThreads[signal] ) do
			endThread( self, thread, signal );
		end
	end
	if self._blockedThreads[signal] then
		local blockedThreadsCopy = TableUtils.shallowCopy( self._blockedThreads[signal] );
		for thread, _ in pairs( blockedThreadsCopy ) do
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

Script.thread = function( self, functionToThread )
	assert( type( functionToThread ) == "function" );
	return coroutine.yield( "fork", self, functionToThread );
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

Script.endOn = function( self, signal )
	assert( type( signal ) == "string" );
	return self:endOnAny( { signal } );
end

Script.endOnAny = function( self, signals )
	assert( type( signals ) == "table" );
	coroutine.yield( "endOnSignals", signals );
end

Script.isDead = function( self )
	return #self._threads == 0;
end

Script.tween = function( self, from, to, duration, easing, set )
	assert( duration >= 0 );
	if duration == 0 then
		set( to );
		return;
	end
	local startTime = self._time;
	while self._time <= ( startTime + duration ) do
		local t = ( self._time - startTime ) / duration;
		local t = MathUtils.ease( t, easing );
		local currentValue = from + t * ( to - from );
		set( currentValue );
		self:waitFrame();
	end
end



return Script;
