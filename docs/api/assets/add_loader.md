---
parent: crystal.assets
grand_parent: API Reference
nav_order: 1
---

# crystal.assets.add_loader

Adds support for a new asset type. This allows you to integrate arbitrary content types with Crystal's asset management system.

## Usage

```lua
crystal.assets.add_loader(extension, loader)
```

### Arguments

| Name        | Type     | Description                                                                             |
| :---------- | :------- | :-------------------------------------------------------------------------------------- |
| `extension` | `string` | File extension (without `.` prefix) of assets for which this loader will be considered. |
| `loader`    | `table`  | Table describing the loader behavior.                                                   |

The `loader` table may define any number of the following functions:

- `can_load(path: string)`: Must return a `boolean` indicating whether the file located under `path` is readable by this loader. You should implement this when multiple loaders apply to the same file extension. An example of this is `lua` assets, which can be [maps](map), [spritesheets](spritesheet) or packages.
- `dependencies(path: string)`: Must return a list of file paths, corresponding to assets required by the asset under `path`.
- `load(path: string)`: Must return the actual asset that will be kept referenced by Crystal, and made available through [crystal.assets.get](get).
- `unload(path: string)`: Called when Crystal drops its last reference to the asset. The asset and its dependencies are still available via [crystal.assets.get](get) during this call.

For assets with the `lua` file extension, Crystal will `require()` the file before selecting and applying a loader. After its loader finishes, the file is automatically un-required by clearing its entry in the `package.loaded` table.

## Examples

This example shows how the `image` loader that is included with Crystal is implemented:

```lua
crystal.assets.add_loader("png", {
  load = function(path)
    local image = love.graphics.newImage(path);
    image:setFilter("nearest");
    return image;
  end,
});
```

This example shows how the `package` loader that is part of Crystal is implemented:

```lua
crystal.assets.add_loader("lua", {
  can_load = function(path)
    local raw = require(path:strip_file_extension());
    return raw.crystal_package == true;
  end,
  dependencies = function(path)
    local raw = require(path:strip_file_extension());
    assert(type(raw.files) == "table");
    return raw.files;
  end,
});
```
