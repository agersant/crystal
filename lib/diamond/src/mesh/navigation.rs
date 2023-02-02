pub use self::builder::NavigationMeshBuilder;
use crate::extensions::*;
use geo::prelude::*;
use geo_types::*;
use ordered_float::OrderedFloat;
use pathfinding::prelude::*;
use spade::delaunay::*;
use spade::kernels::FloatKernel;
use std::collections::HashSet;

mod builder;
mod smoothing;

type Triangulation =
    ConstrainedDelaunayTriangulation<Vertex, FloatKernel, DelaunayTreeLocate<[f32; 2]>>;

pub struct NavigationMesh {
    triangulation: Triangulation,
    navigable_faces: HashSet<FixedFaceHandle>,
}

#[derive(Debug)]
struct ProjectionResult<'a> {
    nearest_point: Point<f32>,
    nearest_face: FaceHandle<'a, Vertex, CdtEdge>,
}

impl NavigationMesh {
    pub fn builder(width: f32, height: f32) -> NavigationMeshBuilder {
        NavigationMeshBuilder::new(width, height)
    }

    pub fn is_face_navigable(&self, face: &FaceHandle<Vertex, CdtEdge>) -> bool {
        self.navigable_faces.contains(&face.fix())
    }

    pub fn get_triangles(&self) -> Vec<Triangle<f32>> {
        let mut triangles = Vec::new();
        for face in self.triangulation.triangles() {
            if !self.navigable_faces.contains(&face.fix()) {
                continue;
            }
            triangles.push(face.to_triangle());
        }
        triangles
    }

    fn project_point_to_nearest_navigable_face<'a>(
        &self,
        point: &Point<f32>,
        candidates: &[FaceHandle<'a, Vertex, CdtEdge>],
    ) -> ProjectionResult<'a> {
        let candidates = candidates
            .iter()
            .filter(|f| self.is_face_navigable(f))
            .collect::<Vec<_>>();

        if let Some(face) = candidates.iter().find(|f| f.to_triangle().contains(point)) {
            return ProjectionResult {
                nearest_point: *point,
                nearest_face: **face,
            };
        }

        candidates
            .iter()
            .map(|f| ProjectionResult {
                nearest_point: f.project_point(point),
                nearest_face: **f,
            })
            .min_by(|a, b| {
                OrderedFloat(a.nearest_point.euclidean_distance(point))
                    .cmp(&OrderedFloat(b.nearest_point.euclidean_distance(point)))
            })
            .unwrap()
    }

    fn project_point_to_playable_space(&self, point: &Point<f32>) -> Option<ProjectionResult> {
        let locate = self.triangulation.locate(&[point.x(), point.y()]);
        let projection = match locate {
            PositionInTriangulation::NoTriangulationPresent => return None,
            PositionInTriangulation::InTriangle(f) => {
                if self.is_face_navigable(&f) {
                    self.project_point_to_nearest_navigable_face(point, &[f])
                } else {
                    self.project_point_to_nearest_navigable_face(point, &f.adjacent_faces())
                }
            }
            PositionInTriangulation::OnPoint(v) => {
                self.project_point_to_nearest_navigable_face(point, &v.adjacent_faces())
            }
            PositionInTriangulation::OutsideConvexHull(e) | PositionInTriangulation::OnEdge(e) => {
                self.project_point_to_nearest_navigable_face(point, &e.adjacent_faces())
            }
        };
        Some(projection)
    }

    pub fn get_nearest_navigable_point(&self, point: &Point<f32>) -> Option<Point<f32>> {
        self.project_point_to_playable_space(point)
            .map(|p| p.nearest_point)
    }

    pub fn compute_path(&self, from: &Point<f32>, to: &Point<f32>) -> Option<LineString<f32>> {
        // Project start and end to playable space
        let from_projection = self.project_point_to_playable_space(from);
        let to_projection = self.project_point_to_playable_space(to);

        if let (Some(mesh_start), Some(mesh_end)) = (&from_projection, &to_projection) {
            // Compute path
            let path = astar(
                &mesh_start.nearest_face.fix(),
                |&face| {
                    let face = self.triangulation.face(face);
                    face.adjacent_edges()
                        .filter(|e| self.is_face_navigable(&e.sym().face()))
                        .map(move |e| {
                            let neighbour = e.sym().face();
                            let cost = movement_cost(&face, &neighbour);
                            (neighbour.fix(), OrderedFloat(cost))
                        })
                },
                |&face| {
                    let face = self.triangulation.face(face);
                    OrderedFloat(heuristic(&face, to))
                },
                |&face| face == mesh_end.nearest_face.fix(),
            );

            // Funnel
            let path = path.map(|(triangle_path, _length)| {
                smoothing::funnel(
                    self,
                    &mesh_start.nearest_point,
                    &mesh_end.nearest_point,
                    triangle_path,
                )
            });

            // Make sure start and end are in the path, in case they were outside of playable area
            if let Some(mut path) = path {
                if *from != mesh_start.nearest_point {
                    path.insert(0, *from);
                }
                if *to != mesh_end.nearest_point {
                    path.push(*to);
                }

                return Some(path.into());
            }
        } else {
            return Some(vec![*from, *to].into());
        }

        None
    }

    #[cfg(test)]
    pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
        let multi_point: MultiPoint<f32> = self
            .triangulation
            .infinite_face()
            .adjacent_edges()
            .map(|e| e.from().to_point())
            .collect::<Vec<_>>()
            .into();
        if multi_point.0.is_empty() {
            return (Point::new(0.0, 0.0), Point::new(0.0, 0.0));
        }
        let extremes = multi_point.extreme_points();
        (
            Point::new(extremes.xmin.x(), extremes.ymin.y()),
            Point::new(extremes.xmax.x(), extremes.ymax.y()),
        )
    }
}

impl Default for NavigationMesh {
    fn default() -> Self {
        NavigationMesh {
            triangulation: FloatCDT::with_tree_locate(),
            navigable_faces: HashSet::new(),
        }
    }
}

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
    let line = Line::new(from.center(), *to);
    line.length()
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
    let line = Line::new(from.center(), to.center());
    line.length()
}

#[cfg(test)]
mod tests {
    use crate::mesh::builder::MeshBuilder;
    use crate::mesh::tests::*;
    use crate::mesh::Mesh;
    use geo::prelude::*;
    use geo_types::*;
    use itertools::*;
    use plotters::style::colors::*;
    use std::fs::File;
    use std::io::BufReader;

    struct Context {
        name: String,
        mesh: Mesh,
    }

    impl Context {
        fn new(name: &str) -> Self {
            let input_file = format!("test-data/{name}-input.json");
            let input_map: InputMap = {
                let file = File::open(input_file).unwrap();
                let reader = BufReader::new(file);
                serde_json::from_reader(reader).unwrap()
            };

            let mut builder =
                MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 16, 16, 4.0);
            for polygon in input_map.polygons.iter() {
                builder.add_polygon(polygon.tile_x, polygon.tile_y, polygon.into());
            }
            let mesh = builder.build();

            Self {
                name: name.to_owned(),
                mesh,
            }
        }

        fn test_exhaustive_paths(&self) {
            let (top_left, bottom_right) = self.mesh.bounding_box();
            let x_min = top_left.x() as i32;
            let y_min = top_left.y() as i32;
            let x_max = bottom_right.x() as i32;
            let y_max = bottom_right.y() as i32;
            let num_steps = 15;
            let step_x = ((x_max - x_min) / num_steps) as usize;
            let step_y = ((y_max - y_min) / num_steps) as usize;

            for (from_x, from_y, to_x, to_y) in iproduct!(
                (x_min..=x_max).step_by(step_x),
                (y_min..=y_max).step_by(step_y),
                (x_min..=x_max).step_by(step_x),
                (y_min..=y_max).step_by(step_y)
            ) {
                let from = Point::new(from_x as f32, from_y as f32);
                if self.mesh.collision.obstacles.contains(&from) {
                    continue;
                }

                let to = Point::new(to_x as f32, to_y as f32);
                if self.mesh.collision.obstacles.contains(&to) {
                    continue;
                }

                if let Some(path) = &self.mesh.navigation.compute_path(&from, &to) {
                    self.validate_path(path, from, to);
                }
            }
        }

        fn test_specific_path(
            &self,
            from: Point<f32>,
            to: Point<f32>,
            expected_path: Option<LineString<f32>>,
        ) {
            if let Some(path) = &expected_path {
                self.draw_test_case("expected", Some((path, &from, &to)));
            }
            let path = self.mesh.navigation.compute_path(&from, &to);
            if let Some(path) = &path {
                self.draw_test_case("actual", Some((path, &from, &to)));
                self.validate_path(path, from, to);
            }
            assert_eq!(path, expected_path);
        }

        fn validate_path(&self, path: &LineString<f32>, from: Point<f32>, to: Point<f32>) {
            assert!(path.num_coords() >= 2);
            assert_eq!(path[0], from.into());
            assert_eq!(path[path.num_coords() - 1], to.into());
            for line in path.lines() {
                if line.start_point() != from && line.end_point() != to {
                    for polygon in &self.mesh.collision.obstacles.0 {
                        // TODO this breaks when running tests with 0 navigation padding
                        let intersects = polygon.intersects(&line);
                        if intersects {
                            self.draw_test_case("actual", Some((path, &from, &to)));
                        }
                        assert!(!intersects);
                    }
                }
            }
        }

        fn draw_test_case(
            &self,
            suffix: &str,
            path: Option<(&LineString<f32>, &Point<f32>, &Point<f32>)>,
        ) {
            let result_file = match path {
                None => format!("test-output/{}-navigation-mesh-{suffix}.png", &self.name,),
                Some((_, from, to)) => format!(
                    "test-output/{}-path-from-({}, {})-to-({}, {})-{suffix}.png",
                    &self.name,
                    from.x(),
                    from.y(),
                    to.x(),
                    to.y(),
                ),
            };
            let mut mesh_painter = MeshPainter::new(&self.mesh, &result_file);
            mesh_painter.clear(&WHITE);

            // Draw collisions
            for contour in self.mesh.collision.get_contours() {
                mesh_painter.draw_line_string(&contour, &RED);
            }

            // Draw navigation
            let triangles = self.mesh.navigation.get_triangles();
            for triangle in triangles {
                let polygon = triangle.to_polygon();
                let line_string = polygon.exterior();
                mesh_painter.draw_line_string(line_string, &CYAN);
            }

            if let Some((path, _, _)) = path {
                mesh_painter.draw_line_string(path, &MAGENTA);
            }
        }
    }

    #[test]
    fn empty() {
        let context = Context::new("empty");
        context.draw_test_case("actual", None);
        context.test_specific_path(
            Point::new(10.0, 20.0),
            Point::new(40.0, 30.0),
            Some(line_string![(x: 10.0, y: 20.0), (x: 40.0, y: 30.0)]),
        );
    }

    #[test]
    fn small() {
        let context = Context::new("small");
        context.draw_test_case("actual", None);
        context.test_specific_path(
            Point::new(50.0, 35.0),
            Point::new(170.0, 35.0),
            Some(line_string![(x: 50.0, y: 35.0), (x: 170.0, y: 35.0)]),
        );
        context.test_specific_path(
		Point::new(40.0, 125.0),
		Point::new(410.0, 220.0),
		Some(line_string![(x: 40.0, y: 125.0), (x: 174.34326, y: 244.0), (x: 353.65674, y: 244.0), (x: 410.0, y: 220.0)]),
	);
        context.test_exhaustive_paths();
    }

    #[test]
    fn large() {
        let context = Context::new("large");
        context.draw_test_case("actual", None);
        context.test_specific_path(Point::new(300.0, 300.0), Point::new(450.0, 500.0), None);
        context.test_exhaustive_paths();
    }
}
