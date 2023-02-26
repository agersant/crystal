---
parent: API Reference
---

# crystal.input

## Functions

| Name                                               | Description                                                             |
| :------------------------------------------------- | :---------------------------------------------------------------------- |
| [crystal.input.player](player)                     | Returns the [InputPlayer](input_player) representing a physical player. |
| [crystal.input.assign_gamepad](assign_gamepad)     | Assigns a gamepad to a player.                                          |
| [crystal.input.unassign_gamepad](unassign_gamepad) | Unassigns a player's current gamepad.                                   |

## Classes

| Name                                    | Description                                                                               |
| :-------------------------------------- | :---------------------------------------------------------------------------------------- |
| [crystal.InputListener](input_listener) | A [Component](/crystal/api/ecs/component) which allows an entity to receive input events. |
| [crystal.InputSystem](input_system)     | A [System](/crystal/api/ecs/system) which dispatches input events.                        |
| [InputPlayer](input_player)             | Object handling keybinds and input events for a player.                                   |
