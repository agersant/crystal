---
parent: crystal.test
grand_parent: API Reference
nav_order: 1
---

# crystal.test.is_running_tests

Returns whether the game is running its test suite or running normally.

## Usage

```lua
crystal.test.is_running_tests()
```

### Returns

| Name            | Type      | Description                                                           |
| :-------------- | :-------- | :-------------------------------------------------------------------- |
| `running_tests` | `boolean` | True if the game was launched to run its test suite, false otherwise. |

## Examples

```lua
crystal.test.add("Can do basic math", function(context)
  print(crystal.test.is_running_tests()); -- Prints "true"
  assert(1 + 1 == 2);
end);
```
