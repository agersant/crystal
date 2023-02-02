use geo::prelude::*;
use geo_types::{Line, LineString, Point};
use itertools::Itertools;

pub trait PointExt {
    fn length(&self) -> f32;
    fn normal(&self, direction: &NormalDirection) -> Point<f32>;
    fn normalize(&self) -> Point<f32>;
}

impl PointExt for Point<f32> {
    fn length(&self) -> f32 {
        (self.x() * self.x() + self.y() * self.y()).sqrt()
    }

    fn normal(&self, direction: &NormalDirection) -> Point<f32> {
        match direction {
            NormalDirection::Left => Point::new(-self.y(), self.x()),
            NormalDirection::Right => Point::new(self.y(), -self.x()),
        }
    }

    fn normalize(&self) -> Point<f32> {
        let length = self.length();
        if length > 0.0 {
            Point::new(self.x() / length, self.y() / length)
        } else {
            *self
        }
    }
}

pub enum NormalDirection {
    Left,
    #[allow(dead_code)]
    Right,
}

pub trait LineExt {
    fn length(&self) -> f32;
    fn intersection(&self, other: &Line<f32>) -> Option<Point<f32>>;
    fn normal(&self, direction: &NormalDirection) -> Point<f32>;
}

impl LineExt for Line<f32> {
    fn length(&self) -> f32 {
        (self.dx() * self.dx() + self.dy() * self.dy()).sqrt()
    }

    fn intersection(&self, other: &Line<f32>) -> Option<Point<f32>> {
        let x1 = self.start.x;
        let y1 = self.start.y;
        let x2 = self.end.x;
        let y2 = self.end.y;
        let x3 = other.start.x;
        let y3 = other.start.y;
        let x4 = other.end.x;
        let y4 = other.end.y;
        let det = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
        if det == 0.0 {
            None
        } else {
            let x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / det;
            let y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / det;
            Some((x, y).into())
        }
    }

    fn normal(&self, direction: &NormalDirection) -> Point<f32> {
        Point::new(self.dx(), self.dy())
            .normal(direction)
            .normalize()
    }
}

pub trait LineStringExt {
    fn offset(&self, amount: f32) -> LineString<f32>;
    fn is_clockwise(&self) -> bool;
}

impl LineStringExt for LineString<f32> {
    fn is_clockwise(&self) -> bool {
        let mut sum = 0.0;
        for line in self.lines() {
            sum += (line.end.x - line.start.x) * (line.end.y + line.start.y);
        }
        sum > 0.0
    }

    fn offset(&self, amount: f32) -> LineString<f32> {
        let amount = if self.is_clockwise() { amount } else { -amount };

        let mut vertices: Vec<Point<f32>> = Vec::new();
        vertices.reserve(self.num_coords());

        let source_vertices = self.clone().into_points();
        let vertex_triplets = source_vertices
            .iter()
            .take(self.num_coords() - 1)
            .cycle()
            .tuple_windows()
            .take(self.num_coords() - 1);

        for (a, b, c) in vertex_triplets {
            let ab = Line::new((a.x(), a.y()), (b.x(), b.y()));
            let bc = Line::new((b.x(), b.y()), (c.x(), c.y()));

            let ab_normal = ab.normal(&NormalDirection::Left);
            let bc_normal = bc.normal(&NormalDirection::Left);

            let padded_ab = ab.translate(ab_normal.x() * amount, ab_normal.y() * amount);
            let padded_bc = bc.translate(bc_normal.x() * amount, bc_normal.y() * amount);

            let intersection = padded_ab.intersection(&padded_bc).unwrap();
            vertices.push(intersection);
        }

        vertices.push(vertices[0]);
        vertices.into()
    }
}

#[cfg(test)]
mod tests {
    use crate::extensions::geo::*;
    use geo_booleanop::boolean::BooleanOp;
    use geo_types::*;

    #[test]
    fn vector_length_zero() {
        let point = Point::new(0.0, 0.0);
        assert_eq!(point.length(), 0.0);
    }

    #[test]
    fn vector_length_non_zero() {
        let point = Point::new(5.0, 0.0);
        assert_eq!(point.length(), 5.0);

        let point = Point::new(5.0, 10.0);
        assert!(point.length() >= 11.18);
        assert!(point.length() <= 11.19);
    }
    #[test]
    fn vector_normalize_zero() {
        let point = Point::new(0.0, 0.0);
        assert_eq!(point.normalize(), Point::new(0.0, 0.0));
    }

    #[test]
    fn vector_normalize_non_zero() {
        let point = Point::new(10.0, 0.0);
        assert_eq!(point.normalize(), Point::new(1.0, 0.0));

        let point = Point::new(20.0, 20.0).normalize();
        assert!(point.x() >= 0.70);
        assert!(point.x() <= 0.71);
        assert_eq!(point.x(), point.y());
    }

    #[test]
    fn vector_normal_left() {
        let n = Point::new(10.0, 0.0)
            .normal(&NormalDirection::Left)
            .normalize();
        assert_eq!(n, Point::new(0.0, 1.0));
    }

    #[test]
    fn vector_normal_right() {
        let n = Point::new(10.0, 0.0)
            .normal(&NormalDirection::Right)
            .normalize();
        assert_eq!(n, Point::new(0.0, -1.0));
    }

    #[test]
    fn line_intersection_simple() {
        let a = Line::new(
            Coordinate { x: 0.0, y: 0.0 },
            Coordinate { x: 10.0, y: 0.0 },
        );
        let b = Line::new(
            Coordinate { x: 5.0, y: 40.0 },
            Coordinate { x: 5.0, y: 1.0 },
        );
        assert_eq!(a.intersection(&b), Some(Point::new(5.0, 0.0)));
    }

    #[test]
    fn line_intersection_parallel() {
        let a = Line::new(
            Coordinate { x: 0.0, y: 0.0 },
            Coordinate { x: 10.0, y: 0.0 },
        );
        let b = Line::new(
            Coordinate { x: 0.0, y: 10.0 },
            Coordinate { x: 10.0, y: 10.0 },
        );
        assert_eq!(a.intersection(&b), None);
    }

    #[test]
    fn line_intersection_same_line() {
        let a = Line::new(
            Coordinate { x: 0.0, y: 0.0 },
            Coordinate { x: 10.0, y: 0.0 },
        );
        let b = Line::new(
            Coordinate { x: 0.0, y: 0.0 },
            Coordinate { x: 10.0, y: 0.0 },
        );
        assert_eq!(a.intersection(&b), None);
    }

    #[test]
    fn line_string_is_clockwise_no() {
        let ls = line_string![
            (x: 50.0, y: 50.0),
            (x: 60.0, y: 50.0),
            (x: 60.0, y: 60.0),
            (x: 50.0, y: 60.0),
            (x: 50.0, y: 50.0),
        ];
        assert!(!ls.is_clockwise());
    }

    #[test]
    fn line_string_is_clockwise_yes() {
        let ls = line_string![
            (x: 50.0, y: 50.0),
            (x: 50.0, y: 60.0),
            (x: 60.0, y: 60.0),
            (x: 60.0, y: 50.0),
            (x: 50.0, y: 50.0),
        ];
        assert!(ls.is_clockwise());
    }

    #[test]
    fn inflate_square_cw() {
        let base = line_string![
            (x: 50.0, y: 50.0),
            (x: 50.0, y: 60.0),
            (x: 60.0, y: 60.0),
            (x: 60.0, y: 50.0),
            (x: 50.0, y: 50.0),
        ];
        let inflated = Polygon::new(base.offset(10.0), vec![]);
        let expected = polygon![
            (x: 40.0, y: 40.0),
            (x: 70.0, y: 40.0),
            (x: 70.0, y: 70.0),
            (x: 40.0, y: 70.0),
            (x: 40.0, y: 40.0),
        ];
        assert!(inflated.xor(&expected).bounding_rect().is_none());
    }

    #[test]
    fn inflate_square_ccw() {
        let base = line_string![
            (x: 50.0, y: 50.0),
            (x: 60.0, y: 50.0),
            (x: 60.0, y: 60.0),
            (x: 50.0, y: 60.0),
            (x: 50.0, y: 50.0),
        ];
        let inflated = Polygon::new(base.offset(10.0), vec![]);
        let expected = polygon![
            (x: 40.0, y: 40.0),
            (x: 70.0, y: 40.0),
            (x: 70.0, y: 70.0),
            (x: 40.0, y: 70.0),
            (x: 40.0, y: 40.0),
        ];
        assert!(inflated.xor(&expected).bounding_rect().is_none());
    }

    #[test]
    fn deflate_square_ccw() {
        let base = line_string![
            (x: 50.0, y: 50.0),
            (x: 60.0, y: 50.0),
            (x: 60.0, y: 60.0),
            (x: 50.0, y: 60.0),
            (x: 50.0, y: 50.0),
        ];
        let inflated = Polygon::new(base.offset(-2.0), vec![]);
        let expected = polygon![
            (x: 52.0, y: 52.0),
            (x: 58.0, y: 52.0),
            (x: 58.0, y: 58.0),
            (x: 52.0, y: 58.0),
            (x: 52.0, y: 52.0),
        ];
        assert!(inflated.xor(&expected).bounding_rect().is_none());
    }

    #[test]
    fn deflate_square_cw() {
        let base = line_string![
            (x: 50.0, y: 50.0),
            (x: 50.0, y: 60.0),
            (x: 60.0, y: 60.0),
            (x: 60.0, y: 50.0),
            (x: 50.0, y: 50.0),
        ];
        let inflated = Polygon::new(base.offset(-2.0), vec![]);
        let expected = polygon![
            (x: 52.0, y: 52.0),
            (x: 58.0, y: 52.0),
            (x: 58.0, y: 58.0),
            (x: 52.0, y: 58.0),
            (x: 52.0, y: 52.0),
        ];
        assert!(inflated.xor(&expected).bounding_rect().is_none());
    }
}
