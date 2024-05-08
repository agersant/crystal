---
parent: crystal.input
grand_parent: API Reference
nav_order: 2
---

# crystal.InputSystem

This ECS [System](system) powers [InputListener](input_listener) components.

When using the `ShowMouseAreaOverlay` command and sending this system a `draw_debug` [notification](/crystal/api/ecs/ecs_notify_systems), it draws the shape of all `MouseArea` components.

## Methods

| Name                                                    | Description                                                                                         |
| :------------------------------------------------------ | :-------------------------------------------------------------------------------------------------- |
| [action_pressed](input_system_action_pressed)           | Routes an action input starting to the relevant [input handlers](input_listener_add_input_handler). |
| [action_released](input_system_action_released)         | Routes an action input stopping to the relevant [input handlers](input_listener_add_input_handler). |
| [mouse_pressed](input_system_mouse_pressed)             | Routes a mouse press event to the relevant [mouse areas](mouse_area).                               |
| [mouse_released](input_system_mouse_released)           | Routes a mouse release event to the relevant [mouse areas](mouse_area).                             |
| [update_mouse_target](input_system_update_mouse_target) | Execute hover-related callbacks on [mouse areas](mouse_area) according to current cursor position.  |

## Console Commands

| Name                   | Description                                  |
| :--------------------- | :------------------------------------------- |
| `HideMouseAreaOverlay` | Stops drawing the shape of all mouse areas.  |
| `ShowMouseAreaOverlay` | Starts drawing the shape of all mouse areas. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.update = function(self, dt)
  self.input_system:update_mouse_target();
end

MyScene.action_pressed = function(self, player_index, action)
  self.input_system:action_pressed(player_index, action);
end

MyScene.action_released = function(self, player_index, action)
  self.input_system:action_released(player_index, action);
end

MyScene.mouse_moved = function(self, x, y, dx, dy, is_touch)
  self.input_system:update_mouse_target();
end

MyScene.mouse_pressed = function(self, x, y, button, is_touch, presses)
  self.input_system:mouse_pressed(x, y, button, is_touch, presses);
end

MyScene.mouse_released = function(self, x, y, button, is_touch, presses)
  self.input_system:mouse_released(x, y, button, is_touch, presses);
end
```
