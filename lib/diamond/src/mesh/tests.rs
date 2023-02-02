use crate::mesh::Mesh;
use geo_types::*;
use plotters::drawing::backend::DrawingBackend;
use plotters::drawing::BitMapBackend;
use plotters::style::RGBColor;
use serde::Deserialize;
use std::path::Path;

#[derive(Debug, Deserialize)]
pub struct InputVertex {
    pub x: f32,
    pub y: f32,
}

#[derive(Debug, Deserialize)]
pub struct InputPolygon {
    #[serde(rename(serialize = "tileX", deserialize = "tileX"))]
    pub tile_x: i32,
    #[serde(rename(serialize = "tileY", deserialize = "tileY"))]
    pub tile_y: i32,
    pub vertices: Vec<InputVertex>,
}

#[derive(Debug, Deserialize)]
pub struct InputMap {
    #[serde(rename(serialize = "numTilesX", deserialize = "numTilesX"))]
    pub num_tiles_x: u32,
    #[serde(rename(serialize = "numTilesY", deserialize = "numTilesY"))]
    pub num_tiles_y: u32,
    pub polygons: Vec<InputPolygon>,
}

pub struct MeshPainter<'a> {
    backend: BitMapBackend<'a>,
    padding: u32,
    top_left: Point<f32>, // map coordinate corresponding lining up with the top-left corner of the draw surface (excluding padding)
}

impl<'a> MeshPainter<'a> {
    pub fn new(mesh: &Mesh, out_file: &'a str) -> Self {
        let path = Path::new(out_file);
        std::fs::create_dir_all(path.parent().unwrap()).unwrap();

        let (top_left, bottom_right) = mesh.bounding_box();
        let width = (bottom_right.x() - top_left.x()).abs().ceil() as u32;
        let height = (bottom_right.y() - top_left.x()).abs().ceil() as u32;

        let padding = 20;
        let backend = BitMapBackend::new(path, (width + 2 * padding, height + 2 * padding));
        MeshPainter {
            backend,
            top_left,
            padding,
        }
    }

    pub fn clear(&mut self, color: &RGBColor) {
        let (width, height) = self.backend.get_size();
        self.backend
            .draw_rect((0, 0), (width as i32 - 1, height as i32 - 1), color, true)
            .unwrap();
    }

    pub fn draw_line_string(&mut self, line_string: &LineString<f32>, color: &RGBColor) {
        let padding = self.padding as f32;

        for line in line_string.lines() {
            let start_point = (
                (padding - self.top_left.x() + line.start.x) as i32,
                (padding - self.top_left.y() + line.start.y) as i32,
            );
            let end_point = (
                (padding - self.top_left.x() + line.end.x) as i32,
                (padding - self.top_left.y() + line.end.y) as i32,
            );

            self.backend
                .draw_line(start_point, end_point, color)
                .unwrap();
        }
        for point in line_string.points_iter() {
            let point = (
                (padding - self.top_left.x() + point.x()) as i32,
                (padding - self.top_left.y() + point.y()) as i32,
            );
            self.backend.draw_circle(point, 2, color, true).unwrap();
        }
    }
}
