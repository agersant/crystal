---
parent: crystal.scene
grand_parent: API Reference
nav_order: 1
---

# LoadScene

This console command replaces the current scene.

## Usage

```
LoadScene scene_class_name:string
```

## Examples

```lua
local TitleScreen = Class("TitleScreen", crystal.Scene);
-- Title screen implementation goes here

crystal.cmd.run("LoadScene TitleScreen");
```
