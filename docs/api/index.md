---
has_children: true
has_toc: false
nav_order: 1
---

# API Reference

## Modules

| Name                         | Description                                                                            |
| :--------------------------- | :------------------------------------------------------------------------------------- |
| [crystal.ai](ai)             | Components facilitating creation of autonomous entities.                               |
| [crystal.assets](assets)     | Loads and unloads game assets (images, spritesheets, maps, etc.).                      |
| [crystal.cmd](cmd)           | Allows you to define and run console commands.                                         |
| [crystal.const](const)       | Allows you to define tweakable variables for fast iteration.                           |
| [crystal.ecs](ecs)           | Implements the Entity Component System pattern.                                        |
| [crystal.graphics](graphics) | Components and classes related to displaying graphics.                                 |
| [crystal.input](input)       | Manages keybindings and routes input events.                                           |
| [crystal.log](log)           | Provides an interface to write log messages to console and to disk.                    |
| [crystal.physics](physics)   | Components allowing entities to move and collide with each other.                      |
| [crystal.scene](scene)       | Manages game scenes and transitions between them.                                      |
| [crystal.script](script)     | Coroutine-based scripting system to write logic that takes place over multiple frames. |
| [crystal.test](test)         | Provides an interface to define unit or integration tests.                             |
| [crystal.tool](tool)         | Allows you to define visual development tools.                                         |
| [crystal.ui](ui)             | Building blocks to create interactive menus and HUDs.                                  |
| [crystal.window](window)     | Handles scaling and letterboxing to support arbitrary window sizes.                    |

## Callbacks

| Name                    | Description |
| :---------------------- | :---------- |
| crystal.developer_start |             |
| crystal.player_start    |             |
| crystal.prelude         |             |
