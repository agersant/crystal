---
parent: crystal.cmd
grand_parent: API Reference
nav_order: 1
---

# crystal.cmd.run

Executes a previously registered command.

## Usage

```lua
crystal.cmd.run(command)
```

### Arguments

| Name      | Type     | Description                                      |
| :-------- | :------- | :----------------------------------------------- |
| `command` | `string` | Console command to run, including its arguments. |

## Examples

```lua
crystal.cmd.add("add a:number b:number", function(a, b)
  print(a + b);
end);

crystal.cmd.run("add 6 3"); -- prints 9
```
