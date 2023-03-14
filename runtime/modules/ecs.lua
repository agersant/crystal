local Component = require("modules/ecs/component");
local ECS = require("modules/ecs/ecs");
local Entity = require("modules/ecs/entity");
local Event = require("modules/ecs/event");
local System = require("modules/ecs/system");

return {
	global_api = {
		Component = Component,
		ECS = ECS,
		Entity = Entity,
		Event = Event,
		System = System,
	},
}
