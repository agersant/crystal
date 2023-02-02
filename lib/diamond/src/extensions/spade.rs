use geo::prelude::*;
use geo::Closest;
use geo_types::*;
use ordered_float::OrderedFloat;
use spade::delaunay::*;

pub type Vertex = [f32; 2];

pub trait VertexHandleExt<'a> {
    fn to_point(self) -> Point<f32>;
    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>>;
}

impl<'a> VertexHandleExt<'a> for &VertexHandle<'a, [f32; 2], CdtEdge> {
    fn to_point(self) -> Point<f32> {
        Point::new(self[0], self[1])
    }

    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>> {
        self.ccw_out_edges().map(|e| e.face()).collect()
    }
}

pub trait EdgeHandleExt<'a> {
    fn to_line(self) -> Line<f32>;
    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>>;
}

impl<'a> EdgeHandleExt<'a> for &EdgeHandle<'a, [f32; 2], CdtEdge> {
    fn to_line(self) -> Line<f32> {
        Line::new(
            Point::new(self.from()[0], self.from()[1]),
            Point::new(self.to()[0], self.to()[1]),
        )
    }

    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>> {
        [self.from(), self.to()]
            .iter()
            .flat_map(|v| v.adjacent_faces())
            .collect()
    }
}

pub trait FaceHandleExt<'a> {
    fn center(self) -> Point<f32>;
    fn to_triangle(self) -> Triangle<f32>;
    fn project_point(self, point: &Point<f32>) -> Point<f32>;
    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>>;
}

impl<'a> FaceHandleExt<'a> for &FaceHandle<'a, [f32; 2], CdtEdge> {
    fn center(self) -> Point<f32> {
        let triangle = self.as_triangle();
        let x = (triangle[0][0] + triangle[1][0] + triangle[2][0]) / 3.0;
        let y = (triangle[0][1] + triangle[1][1] + triangle[2][1]) / 3.0;
        Point::new(x, y)
    }

    fn to_triangle(self) -> Triangle<f32> {
        let t = self.as_triangle();
        Triangle(
            Coordinate {
                x: t[0][0],
                y: t[0][1],
            },
            Coordinate {
                x: t[1][0],
                y: t[1][1],
            },
            Coordinate {
                x: t[2][0],
                y: t[2][1],
            },
        )
    }

    fn project_point(self, point: &Point<f32>) -> Point<f32> {
        let nearest_edge = self
            .adjacent_edges()
            .map(|edge| (edge, OrderedFloat(edge.to_line().euclidean_distance(point))))
            .min_by(|a, b| a.1.cmp(&b.1))
            .unwrap()
            .0;
        match nearest_edge.to_line().closest_point(point) {
            Closest::Intersection(p) => p,
            Closest::SinglePoint(p) => p,
            Closest::Indeterminate => panic!(),
        }
    }

    fn adjacent_faces(self) -> Vec<FaceHandle<'a, Vertex, CdtEdge>> {
        self.as_triangle()
            .iter()
            .flat_map(|v| v.adjacent_faces())
            .collect()
    }
}
