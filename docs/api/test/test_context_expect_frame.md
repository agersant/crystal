---
parent: crystal.test
grand_parent: API Reference
nav_exclude: true
---

# TestContext:expect_frame

Takes a screenshot of the last frame drawn by `love.draw`() and compares it with a reference image. The test will fail if the image is different. Incorrect screenshot can be found under `test-output/screenshots/`.

## Usage

```lua
context:expect_frame(path)
```

### Arguments

| Name   | Type     | Description                  |
| :----- | :------- | ---------------------------- |
| `path` | `string` | Path to the reference image. |

## Examples

```lua
crystal.test.add("Can draw blank screen", { resolution = [1280, 720] }, function(context)
	love.draw();
	-- Validate that the game drew a 1280x720 black frame by comparing the screen with a known image.
	context:expect_frame("test-data/black_1280x720.png");
end);
```
