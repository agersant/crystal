---
parent: crystal.const
grand_parent: API Reference
nav_order: 1
---

# crystal.const.define

Defines a new constant. This function also registers a [console command](/crystal/api/cmd) with the same name to adjust the constant value from the console.

Constant values must be of type `number`, `string` or `boolean`. Constant names are not case sensitive not whitespace sensitive. Built-in constants have `CamelCase` names.

Attempting to redefine an existing constant simply returns its current value.

## Usage

```lua
crystal.const.define(name, initial_value)
```

### Arguments

| Name            | Type     | Description                                                                                                                    |
| :-------------- | :------- | :----------------------------------------------------------------------------------------------------------------------------- |
| `name`          | `string` | Name of this constant.                                                                                                         |
| `initial_value` | `any`    | Initial value of the constant. This will be its only value in [fused builds](https://love2d.org/wiki/love.filesystem.isFused). |

### Returns

| Name    | Type  | Description            |
| :------ | :---- | :--------------------- |
| `value` | `any` | Value of the constant. |

## Usage

```lua
crystal.const.define(name, initial_value, bounds)
```

### Arguments

| Name            | Type                                        | Description                                                                                                                    |
| :-------------- | :------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------- |
| `name`          | `string`                                    | Name of this constant.                                                                                                         |
| `initial_value` | `number`                                    | Initial value of the constant. This will be its only value in [fused builds](https://love2d.org/wiki/love.filesystem.isFused). |
| `bounds`        | `{ min: number \| nil, max:number \| nil }` | Minimum and maximum allowed values for a `number` constant.                                                                    |

### Returns

| Name    | Type     | Description            |
| :------ | :------- | :--------------------- |
| `value` | `number` | Value of the constant. |

## Examples

```lua
crystal.const.define("TransparentBackground", true);
```

```lua
crystal.const.define("WalkSpeed", 10, { min = 1, max = 100 });
```
