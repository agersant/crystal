local CLI = require( "src/dev/cli/CLI" );
local Log = require( "src/dev/Log" );
local Assets = require( "src/resources/Assets" );
local TableUtils = require( "src/utils/TableUtils" );



-- Adapted from lume.hotswap (https://github.com/rxi/lume/)
local reloadModule = function( moduleName )

	local oldGlobal = TableUtils.shallowCopy( _G );
	local updated = {};

	local function update( old, new )
		if updated[old] then
			return;
		end
		updated[old] = true;
		local oldmt, newmt = getmetatable( old ), getmetatable( new );
		if oldmt and newmt then
			update( oldmt, newmt );
		end
		for k, v in pairs( new ) do
			if type( v ) == "table" then
				update( old[k], v )
			else
				old[k] = v;
			end
		end
	end

	local function onError( e )
		for k in pairs( _G ) do
			_G[k] = oldGlobal[k];
		end
		Log:error( "Error while hot-reloading " .. tostring( moduleName ) .. ":\n" .. tostring( e ) );
	end

	local ok, oldmod = pcall( require, moduleName );
	oldmod = ok and oldmod or nil;
	xpcall( function()
		package.loaded[moduleName] = nil;
		local newmod = require( moduleName );
		if type( oldmod ) == "table" then
			update( oldmod, newmod );
		end
		for k, v in pairs( oldGlobal ) do
			if v ~= _G[k] and type(v) == "table" then
				update( v, _G[k] );
				_G[k] = v;
			end
		end
	end, onError );

	package.loaded[moduleName] = false;
end

local hotReload = function()
	local handle = io.popen( "git status" );
	local gitStatus = handle:read("*a");
	handle:close();

	local filenameRegex = "%s+(%g+)%.([%w%d][%w%d]?[%w%d]?[%w%d]?)";
	for file, ext in string.gmatch( gitStatus, filenameRegex ) do
		if ext == "lua" then
			Log:info( "Hot-reloading module: " .. file );
			reloadModule( file );
		end
		Assets:refresh( file .. "." .. ext );
	end

	CLI:execute( "save hot_reload" );
	CLI:execute( "load hot_reload" );
end

CLI:addCommand( "hotReload", hotReload );
