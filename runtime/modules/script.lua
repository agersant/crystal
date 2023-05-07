local Behavior = require(CRYSTAL_RUNTIME .. "/modules/script/behavior");
local Script = require(CRYSTAL_RUNTIME .. "/modules/script/script");
local ScriptRunner = require(CRYSTAL_RUNTIME .. "/modules/script/script_runner");
local ScriptSystem = require(CRYSTAL_RUNTIME .. "/modules/script/script_system");
local Thread = require(CRYSTAL_RUNTIME .. "/modules/script/thread");

return {
	global_api = {
		Behavior = Behavior,
		Script = Script,
		ScriptRunner = ScriptRunner,
		ScriptSystem = ScriptSystem,
		Thread = Thread,
	},
}
