local AISystem = require(CRYSTAL_RUNTIME .. "/modules/ai/ai_system");
local Navigation = require(CRYSTAL_RUNTIME .. "/modules/ai/navigation");

return {
	global_api = {
		AISystem = AISystem,
		Navigation = Navigation,
	}
};
