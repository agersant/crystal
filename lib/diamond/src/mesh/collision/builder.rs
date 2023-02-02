use crate::mesh::collision::CollisionMesh;
use geo::prelude::*;
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;
use ndarray::parallel::prelude::*;
use ndarray::Array;
use ndarray::Array2;
use ndarray::Axis;
use rayon::iter::IndexedParallelIterator;
use rayon::iter::IntoParallelIterator;

#[derive(Debug)]
pub struct CollisionMeshBuilder {
    num_tiles_x: usize,
    num_tiles_y: usize,
    obstacles: Array2<Vec<LineString<f32>>>,
}

impl CollisionMeshBuilder {
    pub fn new(num_tiles_x: usize, num_tiles_y: usize) -> Self {
        CollisionMeshBuilder {
            num_tiles_x,
            num_tiles_y,
            obstacles: Array2::from_elem((num_tiles_y, num_tiles_x), Vec::<LineString<f32>>::new()),
        }
    }

    pub fn add_polygon(&mut self, tile_x: i32, tile_y: i32, line_string: LineString<f32>) {
        if line_string.num_coords() == 0 {
            return;
        }
        let x = tile_x as usize;
        let y = tile_y as usize;
        if x >= self.num_tiles_x || y >= self.num_tiles_y {
            return;
        }
        self.obstacles[(y, x)].push(line_string);
    }

    pub fn build(&self) -> CollisionMesh {
        type P = Polygon<f32>;
        type MP = MultiPolygon<f32>;

        let mut w = self.num_tiles_x;
        let mut h = self.num_tiles_y;

        // Initial state
        let mut reduced_map: Array2<MP> = Array::from_shape_fn((h, w), |(y, x)| {
            let mut union: MP = Vec::<P>::new().into();
            for obstacle in &self.obstacles[(y, x)] {
                let polygon = Polygon::new(obstacle.clone(), Vec::new());
                union = union.union(&polygon);
            }
            union
        });

        // Iterative collapse of 2x2 blocks
        while w > 1 || h > 1 {
            w = (w as f32 / 2.0).ceil() as usize;
            h = (h as f32 / 2.0).ceil() as usize;

            let p: Vec<Vec<MP>> = reduced_map
                .axis_chunks_iter(Axis(0), 2)
                .into_par_iter()
                .enumerate()
                .map(|(y, y_view)| {
                    let polys: Vec<MP> = y_view
                        .axis_chunks_iter(Axis(1), 2)
                        .into_par_iter()
                        .enumerate()
                        .map(|(x, _x_view)| {
                            let mut union: MP = Vec::<P>::new().into();
                            for dx in 0..=1 {
                                for dy in 0..=1 {
                                    if let Some(p) = reduced_map.get((y * 2 + dx, x * 2 + dy)) {
                                        union = union.union(p);
                                    }
                                }
                            }
                            union.simplifyvw(&0.1)
                        })
                        .collect();
                    polys
                })
                .collect();

            reduced_map = Array::from_shape_fn((h, w), |(y, x)| p[y][x].clone());
        }

        CollisionMesh {
            obstacles: reduced_map[(0, 0)].simplifyvw(&0.1),
        }
    }
}
