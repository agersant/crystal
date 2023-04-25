---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.scene

## Overview

This module manages game scenes and transitions between them. In most games, different parts of the game have different logic for updating, drawing and handling input. For example, a game might have a title screen, some playable levels, minigames, and a game over screen. It can be difficult to keep code organized when all of these possible states have to be handled from the same `love.update` or `love.draw` callbacks. [Scenes](scene) are a convenient way to encapsulate these independent game states and easily swap between them. Scene changes can be decorated by [transitions](transition) like color fades, screen wipes, etc.

This module also contains utility classes to work with multiple cameras within a scene. For example your game may use a camera that tracks player position during gameplay, and rely on scripted cameras during cut scenes. Using a [CameraController](camera_controller) lets you keep track of which camera is currently active, and switch between them using [transitions](transition).

### Examples

Scenes are also meant to be the central point where other crystal features (ECS, loading maps, etc.) are brought together into one cohesive whole.

The example below illustrates a very simple title screen scene, which draws a text and moves to a different scene when any key is pressed.

```lua
local TitleScreen = Class("TitleScreen", crystal.Scene);

TitleScreen.draw = function(self)
  love.graphics.print("Legend of Sword", 100, 100);
end

TitleScreen.key_pressed = function(self)
  crystal.scene.replace(
  MyGameScene:new(),
    crystal.Transition.FadeToBlack:new(),
    crystal.Transition.FadeFromBlack:new()
  );
end
```

The example below shows a more comprehensive assemblage of Crystal features. This setup would be useful for most games and can be used as a starting point:

```lua
local Field = Class("Field", crystal.Scene);

Field.init = function(self, map_name)
  self.ecs = crystal.ECS:new();

  self.camera_controller = crystal.CameraController:new();
  self.ecs:add_context("camera_controller", self.camera_controller);

  self.map = crystal.assets.get(map_name);
  self.ecs:add_context("map", self.map);

  self.draw_system = self.ecs:add_system(crystal.DrawSystem);
  self.input_system = self.ecs:add_system(crystal.InputSystem);
  self.physics_system = self.ecs:add_system(crystal.PhysicsSystem);
  self.script_system = self.ecs:add_system(crystal.ScriptSystem);

  self.map:spawn_entities(self.ecs);
end

Field.update = function(self, dt)
  self.ecs:update();
  self.physics_system:simulate_physics(dt);
  self.camera_controller:update(dt);
  self.script_system:run_scripts(dt);
  for _, input in ipairs(crystal.input.player(1):events()) do
    self.input_system:handle_input(1, input);
  end
  self.draw_system:update_drawables(dt);
end

Field.draw = function(self)
  self.camera_controller:draw(function()
    self.draw_system:draw_entities();
    self.ecs:notify_systems("draw_debug");
  end);
end
```

## Functions

| Name                             | Description                                      |
| :------------------------------- | :----------------------------------------------- |
| [crystal.scene.current](current) | Returns the current scene.                       |
| [crystal.scene.replace](replace) | Plays transitions and changes the current scene. |

## Classes

| Name                                          | Description                                                |
| :-------------------------------------------- | :--------------------------------------------------------- |
| [crystal.Camera](camera)                      | Base class for game cameras.                               |
| [crystal.CameraController](camera_controller) | Utility class to handle multiple cameras in a scene.       |
| [crystal.Scene](scene)                        | Game state or level which can draw to the screen.          |
| [crystal.Transition](transition)              | Visual effect to decorate scene changes or camera changes. |
