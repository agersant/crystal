---
parent: crystal.tool
grand_parent: API Reference
nav_order: 1
---

# crystal.tool.show

Makes a tool start drawing on the screen every frame. This also sets the `.visible` field on the tool instance to `true`.

## Usage

```lua
crystal.tool.show(tool_name)
```

### Arguments

| Name        | Type     | Description               |
| :---------- | :------- | :------------------------ |
| `tool_name` | `string` | Name of the tool to show. |

## Examples

```lua
local MyTool = Class("MyTool", crystal.Tool);
crystal.tool.add(MyTool:new());
crystal.tool.show("MyTool");
```
