---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Wrapper:remove_child

Removes the child element from this wrapper.

This method emits an error if the wrapper has no child element.

## Usage

```lua
wrapper:remove_child()
```

## Examples

```lua
local rounded_corners = crystal.RoundedCorners:new();
local image = rounded_corners:set_child(crystal.Image:new());
rounded_corners:remove_child();
assert(image:parent() == nil);
```
