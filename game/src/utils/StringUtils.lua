local StringUtils = {};

StringUtils.trim = function( s )
	return s:match( "^%s*(.-)%s*$" );
end

return StringUtils;
