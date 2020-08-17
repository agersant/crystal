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
