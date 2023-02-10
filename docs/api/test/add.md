---
parent: crystal.test
grand_parent: API Reference
nav_order: 1
---

# crystal.test.add

Defines a test.

## Usage

```lua
crystal.test.add(name, body)
```

### Arguments

| Name   | Type                                      | Description                                                                                |
| :----- | :---------------------------------------- | ------------------------------------------------------------------------------------------ |
| `name` | `string`                                  | The name of the test to display in console output.                                         |
| `body` | `function(`[TestContext](test_context)`)` | The test function to run. Runtime errors or failed `assert()` will cause the test to fail. |

## Usage

```lua
crystal.test.add(name, options, body)
```

### Arguments

| Name      | Type                                      | Description                                                                                |
| :-------- | :---------------------------------------- | ------------------------------------------------------------------------------------------ |
| `name`    | `string`                                  | The name of the test to display in console output.                                         |
| `options` | [TestOptions](test_options)               | Options determining the pre-conditions before this test runs.                              |
| `body`    | `function(`[TestContext](test_context)`)` | The test function to run. Runtime errors or failed `assert()` will cause the test to fail. |

## Examples

```lua
crystal.test.add("Can do basic math", function(context)
	assert(1 + 1 == 2);
end);
```

```lua
crystal.test.add("Can draw blank screen", { gfx = true, resolution = [200, 200] }, function(context)
	love.draw();
	-- Validate that the game drew a 200x200 black frame by comparing the screen with a known image.
	context:expect_frame("test-data/black_200x200.png");
end);
```
