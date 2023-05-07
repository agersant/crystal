local Component = require(CRYSTAL_RUNTIME .. "/modules/ecs/component");
local ECS = require(CRYSTAL_RUNTIME .. "/modules/ecs/ecs");
local Entity = require(CRYSTAL_RUNTIME .. "/modules/ecs/entity");
local Event = require(CRYSTAL_RUNTIME .. "/modules/ecs/event");
local System = require(CRYSTAL_RUNTIME .. "/modules/ecs/system");

return {
	global_api = {
		Component = Component,
		ECS = ECS,
		Entity = Entity,
		Event = Event,
		System = System,
	},
}
