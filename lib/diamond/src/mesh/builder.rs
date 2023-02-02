use crate::mesh::collision::*;
use crate::mesh::navigation::*;
use crate::mesh::Mesh;
use geo_types::*;

#[derive(Debug)]
pub struct MeshBuilder {
    collision_mesh_builder: CollisionMeshBuilder,
    navigation_mesh_builder: NavigationMeshBuilder,
}

impl MeshBuilder {
    pub fn new(
        num_tiles_x: u32,
        num_tiles_y: u32,
        tile_width: u32,
        tile_height: u32,
        navigation_padding: f32,
    ) -> MeshBuilder {
        let collision_mesh_builder =
            CollisionMesh::builder(num_tiles_x as usize, num_tiles_y as usize);

        let map_width = num_tiles_x as f32 * tile_width as f32;
        let map_height = num_tiles_y as f32 * tile_height as f32;
        let navigation_mesh_builder =
            NavigationMesh::builder(map_width, map_height).padding(navigation_padding);

        MeshBuilder {
            collision_mesh_builder,
            navigation_mesh_builder,
        }
    }

    pub fn add_polygon(&mut self, tile_x: i32, tile_y: i32, line_string: LineString<f32>) {
        self.collision_mesh_builder
            .add_polygon(tile_x, tile_y, line_string);
    }

    pub fn build(&self) -> Mesh {
        let collision_mesh = self.collision_mesh_builder.build();

        let navigation_mesh = self.navigation_mesh_builder.build(&collision_mesh);
        Mesh {
            collision: collision_mesh,
            navigation: navigation_mesh,
        }
    }
}
