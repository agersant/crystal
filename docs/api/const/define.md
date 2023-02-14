---
parent: crystal.const
grand_parent: API Reference
nav_order: 1
---

# crystal.const.define

Defines a new constant.

If the constant is a `number`, a `string` or a `boolean`, this function also registers a [console command](/crystal/api/cmd) with the same name to adjust it.

## Usage

```lua
crystal.const.define(name, initial_value, bounds)
```

### Arguments

| Name            | Type                          | Description                                                                                                                    |
| :-------------- | :---------------------------- | :----------------------------------------------------------------------------------------------------------------------------- |
| `name`          | `string`                      | Name of this constant.                                                                                                         |
| `initial_value` | `number`                      | Initial value of the constant. This will be its only value in [fused builds](https://love2d.org/wiki/love.filesystem.isFused). |
| `bounds`        | `{ min: number, max:number }` | Minimum and maximum allowed values for this constant.                                                                          |

Note that the `bounds` table is a required argument when defining `number` constants.

## Usage

```lua
crystal.const.define(name, initial_value)
```

### Arguments

| Name            | Type     | Description                                                                                                                    |
| :-------------- | :------- | :----------------------------------------------------------------------------------------------------------------------------- |
| `name`          | `string` | Name of this constant.                                                                                                         |
| `initial_value` | `any`    | Initial value of the constant. This will be its only value in [fused builds](https://love2d.org/wiki/love.filesystem.isFused). |

## Examples

```lua
crystal.const.define("transparent_background", true);
```

```lua
crystal.const.define("walk_speed", 10, { min = 1, max = 100 });
```
