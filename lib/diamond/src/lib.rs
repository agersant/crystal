use geo::Point;
use mlua::prelude::*;

use mesh::{builder::MeshBuilder, Mesh};

mod extensions;
mod mesh;

impl LuaUserData for MeshBuilder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut(
            "addPolygon",
            |_, builder, (tile_x, tile_y, vertices): (i32, i32, Vec<[f32; 2]>)| {
                let vertices = vertices
                    .into_iter()
                    .map(|v| v.into())
                    .collect::<Vec<Point<f32>>>()
                    .into();
                builder.add_polygon(tile_x, tile_y, vertices);
                Ok(())
            },
        );

        methods.add_method("buildMesh", |_, builder, _: ()| Ok(builder.build()));
    }
}

impl LuaUserData for Mesh {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("getNearestNavigablePoint", |_, mesh, (x, y)| {
            Ok(mesh
                .navigation
                .get_nearest_navigable_point(&Point::new(x, y))
                .map(|p| [p.x(), p.y()]))
        });

        methods.add_method("listCollisionPolygons", |_, mesh, _: ()| {
            let polygons: Vec<Vec<[f32; 2]>> = mesh
                .collision
                .get_contours()
                .into_iter()
                .map(|c| c.points_iter().map(|p| [p.x(), p.y()]).collect())
                .collect();
            Ok(polygons)
        });

        methods.add_method("listNavigationPolygons", |_, mesh, _: ()| {
            let polygons: Vec<Vec<[f32; 2]>> = mesh
                .navigation
                .get_triangles()
                .into_iter()
                .map(|t| t.to_array().iter().map(|c| [c.x, c.y]).collect())
                .collect();
            Ok(polygons)
        });

        methods.add_method("planPath", |_, mesh, (start_x, start_y, end_x, end_y)| {
            let start = Point::new(start_x, start_y);
            let end = Point::new(end_x, end_y);
            let path: Option<Vec<[f32; 2]>> = mesh
                .navigation
                .compute_path(&start, &end)
                .map(|c| c.points_iter().map(|p| [p.x(), p.y()]).collect());
            Ok(path)
        });
    }
}

#[mlua::lua_module]
fn diamond(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "newMeshBuilder",
        lua.create_function(
            |_, (num_tiles_x, num_tiles_y, tile_width, tile_height, navigation_padding)| {
                let builder = MeshBuilder::new(
                    num_tiles_x,
                    num_tiles_y,
                    tile_width,
                    tile_height,
                    navigation_padding,
                );
                Ok(builder)
            },
        )?,
    )?;

    Ok(exports)
}
