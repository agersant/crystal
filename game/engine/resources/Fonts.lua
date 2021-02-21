require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Module = require("engine/Module");

local Fonts = Class("Fonts");

local pickFont = function(self, name)
	if name == "dev" then
		return "engine/assets/source_code_pro_medium.otf";
	end
	if name == "devBold" then
		return "engine/assets/source_code_pro_bold.otf";
	end
	if name == "devCondensed" then
		return "engine/assets/open_sans_condensed_bold.ttf";
	end
	local font = self._list[name];
	return font or error("Unknown font: " .. tostring(name));
end

Fonts.init = function(self, list)
	assert(list);
	self._list = list;
	self._fontObjects = {};
end

Fonts.get = function(self, name, size)
	if self._fontObjects[name] and self._fontObjects[name][size] then
		return self._fontObjects[name][size];
	end
	self._fontObjects[name] = self._fontObjects[name] or {};
	assert(not self._fontObjects[name][size]);

	local fontFile = pickFont(self, name);
	self._fontObjects[name][size] = love.graphics.newFont(fontFile, size);
	self._fontObjects[name][size]:setFilter("nearest");
	Log:info("Registered font " .. fontFile .. " at size " .. size);
	return self._fontObjects[name][size];
end

return Fonts;
