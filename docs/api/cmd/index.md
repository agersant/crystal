---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.cmd

Commands are a convenient way to access debug functionality in your game. For example, you can add commands to toggle cheats, to skip between different scenes, or to enable debug visualizations.

Commands can be executed programmatically via [crystal.cmd.run](run), or using the on-screen [console](/crystal/tools/console) available by pressing **`** (backtick key) while the game is running.

The following example defines and immediately calls a command to print a number:

```lua
crystal.cmd.add("greet name:string", function(name)
  print("Hello " .. name);
end);

crystal.cmd.run("greet Crystal"); -- prints "Hello Crystal"
```

## Functions

| Name                   | Description                      |
| :--------------------- | :------------------------------- |
| [crystal.cmd.add](add) | Registers a new console command. |
| [crystal.cmd.run](run) | Executes a console command.      |
