---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.scene

This module manages game scenes and transitions between them.

## Functions

| Name                             | Description                 |
| :------------------------------- | :-------------------------- |
| [crystal.scene.current](current) | Returns the current scene.  |
| [crystal.scene.replace](replace) | Replaces the current scene. |

## Classes

| Name                                          | Description                                                |
| :-------------------------------------------- | :--------------------------------------------------------- |
| [crystal.Camera](camera)                      | Base class for game cameras.                               |
| [crystal.CameraController](camera_controller) | Utility class to handle multiple cameras in a scene.       |
| [crystal.Scene](scene)                        | Game state or level which can draw to the screen.          |
| [crystal.Transition](transition)              | Visual effect to decorate scene changes or camera changes. |
