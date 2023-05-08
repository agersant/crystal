---
parent: crystal.scene
grand_parent: API Reference
nav_order: 3
---

# LoadScene

This console command [replaces](replace) the current scene.

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
