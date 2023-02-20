local Behavior = require("modules/script/behavior");
local Script = require("modules/script/script");
local ScriptRunner = require("modules/script/script_runner");
local ScriptSystem = require("modules/script/script_system");
local Thread = require("modules/script/thread");

return {
	global_api = {
		Behavior = Behavior,
		Script = Script,
		ScriptRunner = ScriptRunner,
		ScriptSystem = ScriptSystem,
		Thread = Thread,
	},
}
