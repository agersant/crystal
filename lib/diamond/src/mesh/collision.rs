pub use self::builder::CollisionMeshBuilder;
use geo::prelude::*;
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;

mod builder;

#[derive(Debug)]
pub struct CollisionMesh {
    pub obstacles: MultiPolygon<f32>,
}

impl Default for CollisionMesh {
    fn default() -> Self {
        let polygons: Vec<Polygon<f32>> = Vec::new();
        CollisionMesh {
            obstacles: polygons.into(),
        }
    }
}

impl PartialEq for CollisionMesh {
    fn eq(&self, other: &Self) -> bool {
        let xor = self.obstacles.xor(&other.obstacles);
        xor.bounding_rect().is_none()
    }
}

impl CollisionMesh {
    pub fn builder(num_tiles_x: usize, num_tiles_y: usize) -> CollisionMeshBuilder {
        CollisionMeshBuilder::new(num_tiles_x, num_tiles_y)
    }

    pub fn get_contours(&self) -> Vec<LineString<f32>> {
        let mut polygons: Vec<LineString<f32>> = Vec::new();
        for polygon in &self.obstacles.0 {
            let exterior_vertices = polygon.exterior().clone().into_points();
            polygons.push(exterior_vertices.into());
            for interior in polygon.interiors() {
                let interior_vertices = interior.clone().into_points();
                polygons.push(interior_vertices.into());
            }
        }
        polygons
    }

    #[cfg(test)]
    pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
        if self.obstacles.0.is_empty() {
            return (Point::new(0.0, 0.0), Point::new(0.0, 0.0));
        }
        let extremes = self.obstacles.extreme_points();
        (
            Point::new(extremes.xmin.x(), extremes.ymin.y()),
            Point::new(extremes.xmax.x(), extremes.ymax.y()),
        )
    }
}

#[cfg(test)]
mod tests {
    use crate::mesh::builder::MeshBuilder;
    use crate::mesh::collision::*;
    use crate::mesh::tests::*;
    use crate::mesh::Mesh;
    use plotters::style::colors::*;
    use serde::Deserialize;
    use std::fs::File;
    use std::io::BufReader;

    fn draw_collision_mesh(mesh: &Mesh, out_file: &str) {
        let mut mesh_painter = MeshPainter::new(mesh, out_file);
        mesh_painter.clear(&WHITE);
        for contour in mesh.collision.get_contours() {
            mesh_painter.draw_line_string(&contour, &RED);
        }
    }

    #[derive(Debug, Deserialize)]
    struct InputMesh(Vec<Vec<InputVertex>>);

    impl From<&InputVertex> for Point<f32> {
        fn from(input: &InputVertex) -> Point<f32> {
            Point::new(input.x, input.y)
        }
    }

    impl From<&InputPolygon> for LineString<f32> {
        fn from(input: &InputPolygon) -> LineString<f32> {
            LineString::from(
                input
                    .vertices
                    .iter()
                    .map(|v| v.into())
                    .collect::<Vec<Point<f32>>>(),
            )
        }
    }

    fn run_test_case(name: &str) {
        let input_file = format!("test-data/{name}-input.json");
        let input_map: InputMap = {
            let file = File::open(input_file).unwrap();
            let reader = BufReader::new(file);
            serde_json::from_reader(reader).unwrap()
        };

        let expected_collision_mesh_file = format!("test-data/{name}-collision-mesh.json");
        let expected_collision_mesh = {
            let file = File::open(expected_collision_mesh_file).unwrap();
            let reader = BufReader::new(file);
            let obstacles = serde_json::from_reader(reader).unwrap();
            CollisionMesh { obstacles }
        };
        let expected_mesh = Mesh {
            collision: expected_collision_mesh,
            ..Default::default()
        };

        let mut builder =
            MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 16, 16, 4.0);
        for polygon in input_map.polygons.iter() {
            builder.add_polygon(polygon.tile_x, polygon.tile_y, polygon.into());
        }
        let actual_mesh = builder.build();

        let expected_result_file = format!("test-output/{name}-collision-mesh-expected.png");
        draw_collision_mesh(&expected_mesh, &expected_result_file);

        let actual_result_file = format!("test-output/{name}-collision-mesh-actual.png");
        draw_collision_mesh(&actual_mesh, &actual_result_file);

        assert_eq!(actual_mesh.collision, expected_mesh.collision);
    }

    #[test]
    fn compare_meshes_equal_trivially_different() {
        let a = CollisionMesh {
            obstacles: vec![polygon![
                (x: 16.0, y: 32.0),
                (x: 0.0, y: 0.0),
                (x: 128.0, y: 0.0),
                (x: 128.0, y: 16.0),
                (x: 16.0, y: 16.0),
                (x: 16.0, y: 32.0),
            ]]
            .into(),
        };

        let b = CollisionMesh {
            obstacles: vec![polygon![
                (x: 20.0, y: 20.0),
                (x: 10.0, y: 20.0),
                (x: 10.0, y: 10.0),
                (x: 20.0, y: 20.0),
            ]]
            .into(),
        };

        assert_ne!(a, b);
    }

    #[test]
    fn compare_meshes_different_but_overlapping() {
        let a = CollisionMesh {
            obstacles: vec![polygon![
                (x: 0.0, y: 0.0),
                (x: 10.0, y: 0.0),
                (x: 10.0, y: 10.0),
                (x: 0.0, y: 10.0),
                (x: 0.0, y: 0.0),
            ]]
            .into(),
        };

        let b = CollisionMesh {
            obstacles: vec![polygon![
                (x: 0.0, y: 0.0),
                (x: 20.0, y: 0.0),
                (x: 20.0, y: 10.0),
                (x: 0.0, y: 10.0),
                (x: 0.0, y: 0.0),
            ]]
            .into(),
        };

        assert_ne!(a, b);
    }

    #[test]
    fn compare_meshes_cycled_vertices_and_polygons() {
        let a = CollisionMesh {
            obstacles: vec![
                polygon![
                    (x: 16.0, y: 32.0),
                    (x: 0.0, y: 0.0),
                    (x: 128.0, y: 0.0),
                    (x: 128.0, y: 16.0),
                    (x: 16.0, y: 16.0),
                    (x: 16.0, y: 32.0),
                ],
                polygon![
                    (x: 10.0, y: 10.0),
                    (x: 20.0, y: 20.0),
                    (x: 10.0, y: 20.0),
                    (x: 10.0, y: 10.0),
                ],
            ]
            .into(),
        };

        let b = CollisionMesh {
            obstacles: vec![
                polygon![
                    (x: 20.0, y: 20.0),
                    (x: 10.0, y: 20.0),
                    (x: 10.0, y: 10.0),
                    (x: 20.0, y: 20.0),
                ],
                polygon![
                    (x: 0.0, y: 0.0),
                    (x: 128.0, y: 0.0),
                    (x: 128.0, y: 16.0),
                    (x: 16.0, y: 16.0),
                    (x: 16.0, y: 32.0),
                    (x: 0.0, y: 0.0),
                ],
            ]
            .into(),
        };

        assert_eq!(a, b);
    }

    #[test]
    fn trivial() {
        run_test_case("trivial");
    }

    #[test]
    fn small() {
        run_test_case("small");
    }

    #[test]
    fn large() {
        run_test_case("large");
    }

    #[test]
    fn overlap() {
        run_test_case("overlap");
    }

    #[test]
    fn asymetric_collapse() {
        run_test_case("asymetric-collapse");
    }
}
