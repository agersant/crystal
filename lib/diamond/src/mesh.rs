use crate::mesh::collision::CollisionMesh;
use crate::mesh::navigation::NavigationMesh;
#[cfg(test)]
use geo_types::*;

pub mod builder;
pub mod collision;
pub mod navigation;
#[cfg(test)]
pub mod tests;

// TODO replace geo_booleanop::boolean::BooleanOp with new built-in implementation
// See: https://github.com/georust/geo/pull/835

#[derive(Default)]
pub struct Mesh {
    pub collision: CollisionMesh,
    pub navigation: NavigationMesh,
}

impl Mesh {
    #[cfg(test)]
    pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
        use geo::prelude::*;

        let mut points = Vec::new();

        let (top_left, bottom_right) = self.collision.bounding_box();
        points.push(top_left);
        points.push(bottom_right);

        let (top_left, bottom_right) = self.navigation.bounding_box();
        points.push(top_left);
        points.push(bottom_right);

        let multi_point: MultiPoint<f32> = points.into();
        let extremes = multi_point.extreme_points();
        (
            Point::new(extremes.xmin.x(), extremes.ymin.y()),
            Point::new(extremes.xmax.x(), extremes.ymax.y()),
        )
    }
}
