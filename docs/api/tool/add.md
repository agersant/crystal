---
parent: crystal.tool
grand_parent: API Reference
nav_order: 1
---

# crystal.tool.add

Defines a new tool.

## Usage

```lua
crystal.tool.add(tool)
```

### Arguments

| Name   | Type                 | Description                  |
| :----- | :------------------- | :--------------------------- |
| `tool` | [crystal.Tool](tool) | Instance of the tool to add. |

## Usage

```lua
crystal.tool.add(tool, options)
```

### Arguments

| Name      | Type                 | Description                                         |
| :-------- | :------------------- | :-------------------------------------------------- |
| `tool`    | [crystal.Tool](tool) | Instance of the tool to add.                        |
| `options` | `table`              | Additional options specifying behavior of the tool. |

The `options` table supports the following values:

| Name           | Type                                                    | Default                                      | Description                                                                                |
| :------------- | :------------------------------------------------------ | :------------------------------------------- | :----------------------------------------------------------------------------------------- |
| `keybind`      | [love.KeyConstant](https://love2d.org/wiki/KeyConstant) | `nil`                                        | Associates a keybind with this tool. Pressing this key will toggle visibility of the tool. |
| `hide_command` | `string`                                                | `nil`                                        | Automatically registers a [console command](/crystal/api/cmd) to hide this tool.           |
| `name`         | `string`                                                | Class name of the tool (`tool:class_name()`) | A name used to identify this tool when calling other `crystal.tool.*` functions.           |
| `show_command` | `string`                                                | `nil`                                        | Automatically registers a [console command](/crystal/api/cmd) to show this tool.           |

## Examples

```lua
local MyTool = Class("MyTool", crystal.Tool);

MyTool.draw = function()
  love.graphics.rectangle("fill", 20, 50, 60, 120);
end

crystal.tool.add(MyTool:new());
crystal.tool.show("MyTool");
```

```lua
local MyTool = Class("MyTool", crystal.Tool);

MyTool.draw = function()
  love.graphics.rectangle("fill", 20, 50, 60, 120);
end

crystal.tool.add(MyTool:new(), { name = "my-favorite-tool" });
crystal.tool.show("my-favorite-tool");
```
