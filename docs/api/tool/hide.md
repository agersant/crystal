---
parent: crystal.tool
grand_parent: API Reference
nav_order: 1
---

# crystal.tool.hide

Stops a tool from drawing on the screen. This also sets the `.visible` field on the tool instance to `false`.

## Usage

```lua
crystal.tool.hide(tool_name)
```

### Arguments

| Name        | Type     | Description               |
| :---------- | :------- | :------------------------ |
| `tool_name` | `string` | Name of the tool to hide. |

## Examples

```lua
local MyTool = Class("MyTool", crystal.Tool);
crystal.tool.add(MyTool:new());
crystal.tool.hide("MyTool");
```
