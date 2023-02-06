local Game = Class("Game");

Game.init = function(self)
	self.classes = { MapScene = require("mapscene/MapScene"),
		SaveData = require("persistence/BaseSaveData") };
	self.mapDirectory = "engine/assets";
	self.testFiles = {};
	self.fonts = {};
	self.maxLocalPlayers = 1;
	self.defaultBindings = {};
end

return Game;
