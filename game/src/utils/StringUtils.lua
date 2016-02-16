local StringUtils = {};

StringUtils.trim = function( s )
	return s:match( "^%s*(.-)%s*$" );
end

StringUtils.fileExtension = function( path )
	return path:match( "%.(.+)$" );
end

StringUtils.stripFileExtension = function( path )
	return path:match( "^(.*)%..+$" );
end

return StringUtils;
