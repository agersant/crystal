---
parent: crystal.cmd
grand_parent: API Reference
nav_order: 1
---

# crystal.cmd.add

Defines a new console command.

Command names are not case sensitive. Built-in commands have `CamelCase` names.

## Usage

```lua
crystal.cmd.add(signature, implementation)
```

### Arguments

| Name             | Type            | Description                                                                                                                                                                                   |
| :--------------- | :-------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `signature`      | `string`        | The name of the command followed by its parameters and their types. Parameter names and their types must be separated by a colon (`:`). Supported types are `string`, `number` and `boolean`. |
| `implementation` | `function(...)` | Function that will be called when this command is invoked.                                                                                                                                    |

## Examples

```lua
crystal.cmd.add("SkipLevel", function()
  -- Logic to skip level here
end);
```

```lua
crystal.cmd.add("Add a:number b:number", function(a, b)
  print(a + b);
end);
crystal.cmd.run("Add 6 3"); -- prints 9
```
