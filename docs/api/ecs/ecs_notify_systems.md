---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:notify_systems

Calls a method by name on all systems that support it.

This method is the entry point to run game logic implemented in [Systems](system). The expected usage is to divide your game frame into various stages (eg. `before_physics`, `input`, `draw`, `draw_debug`, etc.) and call this method once for each stage name. Systems that have work to do at different points in the frame can implement methods named after these stages.

When multiple systems implement the specified method, they are called in the order the systems were created.

## Usage

```lua
ecs:notify_systems(method_name, ...)
```

### Arguments

| Name          | Type     | Description                                                              |
| :------------ | :------- | :----------------------------------------------------------------------- |
| `method_name` | `string` | Name of the method that will be called on all systems that implement it. |
| `...`         | `any`    | Parameters for the method call.                                          |

## Examples

```lua
-- Somewhere in your scene's update code:
my_ecs:update();
my_ecs:notify_systems("input");
my_ecs:notify_systems("physics", dt);
my_ecs:notify_systems("combat", dt);
my_ecs:notify_systems("draw");
```
