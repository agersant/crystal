---
parent: API reference
nav_exclude: true
---

# crystal.configure

Call this function from `main.lua` to configure crystal's behavior.

## Usage

```lua
crystal.configure(configuration)
```

### Arguments

| Name            | Type    | Description                       |
| :-------------- | :------ | :-------------------------------- |
| `configuration` | `table` | A table of configuration options. |

The `configuration` table supports the following values:

- `physics_categories`: list of categories (as strings) that can be used in [physics components](/crystal/api/physics).

## Examples

```lua
crystal.configure({
	physics_categories = { "character", "monster", "powerup", "hitbox", "trigger" },
});
```
