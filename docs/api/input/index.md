---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.input

The classes and functions in this module allow you to:

- Manage which physical buttons correspond to which actions in your game.
- Manage which devices corresponding to which player (in a multiplayer game).
- Route input events to specific game [entities](/crystal/api/ecs/entity) like player characters.

Each real-life player in your game is represented by a persistent [InputPlayer](input_player), which is accessed by calling [crystal.input.player](player). These objects manage key bindings for the corresponding player (eg. `spacebar` means `jump` for player 1). During gameplay, they also keep track of what actions (eg. `jump`) are currently being pressed.

An [InputPlayer](input_player) can have bindings to both keyboard and gamepad buttons at the same time. This allows players to seemlessly switch between input methods. For singleplayer games, you do not have to do anything related to [assigning](assign_gamepad) or [unassigning](unassign_gamepad) gamepads.

By adding an [InputListener](input_listener) component on an entity, you can make it respond to input events from a specific [InputPlayer](input_player).

## Functions

| Name                                                                           | Description                                                                               |
| :----------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------- |
| [crystal.input.player](player)                                                 | Returns the [InputPlayer](input_player) representing a player.                            |
| [crystal.input.assign_gamepad](assign_gamepad)                                 | Assigns a gamepad to a player.                                                            |
| [crystal.input.map_axis_to_actions](map_axis_to_actions)                       | Map positions on gamepad analog axis to binary actions.                                   |
| [crystal.input.configure_autorepeat](configure_autorepeat)                     | Defines which actions emit events while inputs are being held, and how frequently.        |
| [crystal.input.set_unassigned_gamepad_handler](set_unassigned_gamepad_handler) | Defines a callback function which runs when a button is pressed on an unassigned gamepad. |
| [crystal.input.unassign_gamepad](unassign_gamepad)                             | Unassigns a player's current gamepad.                                                     |

## Classes

| Name                                    | Description                                                                               |
| :-------------------------------------- | :---------------------------------------------------------------------------------------- |
| [crystal.InputListener](input_listener) | A [Component](/crystal/api/ecs/component) which allows an entity to receive input events. |
| [crystal.InputSystem](input_system)     | A [System](/crystal/api/ecs/system) which dispatches input events.                        |
| [InputPlayer](input_player)             | Object handling keybinds and input events for a player.                                   |
