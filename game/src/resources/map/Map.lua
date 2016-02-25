require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Layer = require( "src/resources/map/Layer" );


local Map = Class( "Map" );



Map.init = function( self, mapData, tileset )
	self.layers = {};
	for i, layerData in ipairs( mapData.content.layers ) do
		if layerData.type == "tilelayer" then
			local layer = Layer:new( mapData, tileset, layerData );
			table.insert( self.layers, layer );
		end
	end
end

Map.draw = function( self )
	for i, layer in ipairs( self.layers ) do
		if layer:isBelowSprites() then
			layer:draw();
		end
	end
	for i, layer in ipairs( self.layers ) do
		if layer:isAboveSprites() then
			layer:draw();
		end
	end
end



return Map;
