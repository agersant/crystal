local Component = require("modules/ecs/Component");
local ECS = require("modules/ecs/ECS");
local Entity = require("modules/ecs/Entity");
local Event = require("modules/ecs/Event");
local System = require("modules/ecs/System");

return {
	global_api = {
		Component = Component,
		ECS = ECS,
		Entity = Entity,
		Event = Event,
		System = System,
	},
}
