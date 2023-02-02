use crate::mesh::navigation::NavigationMesh;
use geo_types::*;
use itertools::Itertools;
use spade::delaunay::*;

fn triangle_double_area(a: &Point<f32>, b: &Point<f32>, c: &Point<f32>) -> f32 {
    let ax = b.x() - a.x();
    let ay = b.y() - a.y();
    let bx = c.x() - a.x();
    let by = c.y() - a.y();
    bx * ay - ax * by
}

fn list_portals(
    navigation_mesh: &NavigationMesh,
    triangle_path: Vec<FixedFaceHandle>,
) -> Vec<Line<f32>> {
    triangle_path
        .iter()
        .tuple_windows()
        .map(|(a, b)| {
            let face_a = navigation_mesh.triangulation.face(*a);
            let face_b = navigation_mesh.triangulation.face(*b);
            face_a
                .adjacent_edges()
                .find(|e| e.sym().face() == face_b)
                .map(|e| {
                    Line::new(
                        Point::new(e.to()[0], e.to()[1]),
                        Point::new(e.from()[0], e.from()[1]),
                    )
                })
                .unwrap()
        })
        .collect()
}

// Based on http://digestingduck.blogspot.com/2010/03/simple-stupid-funnel-algorithm.html
pub fn funnel(
    navigation_mesh: &NavigationMesh,
    from: &Point<f32>,
    to: &Point<f32>,
    triangle_path: Vec<FixedFaceHandle>,
) -> Vec<Point<f32>> {
    let mut path = Vec::new();

    if triangle_path.len() <= 1 {
        path.push(*from);
        path.push(*to);
        return path;
    }

    let mut portals = Vec::new();
    portals.push(Line::new(*from, *from));
    portals.append(&mut list_portals(navigation_mesh, triangle_path));
    portals.push(Line::new(*to, *to));

    let mut apex_index;
    let mut left_index = 0;
    let mut right_index = 0;
    let mut portal_apex = *from;
    let mut portal_left = *from;
    let mut portal_right = *from;

    path.push(*from);

    let mut i = 1;
    while i < portals.len() {
        let portal = &portals[i];

        if triangle_double_area(&portal_apex, &portal_right, &portal.end_point()) <= 0.0 {
            if portal_apex == portal_right
                || triangle_double_area(&portal_apex, &portal_left, &portal.end_point()) > 0.0
            {
                portal_right = portal.end_point();
                right_index = i;
            } else {
                // Left over right, insert right to path and restart scan from portal right point
                if path.is_empty() || portal_left != path[path.len() - 1] {
                    path.push(portal_left);
                }
                // Make current left the new apex
                portal_apex = portal_left;
                apex_index = left_index;
                // Reset portal
                portal_left = portal_apex;
                portal_right = portal_apex;
                left_index = apex_index;
                right_index = apex_index;
                // Restart scan
                i = apex_index + 1;
                continue;
            }
        }

        if triangle_double_area(&portal_apex, &portal_left, &portal.start_point()) >= 0.0 {
            if portal_apex == portal_left
                || triangle_double_area(&portal_apex, &portal_right, &portal.start_point()) < 0.0
            {
                portal_left = portal.start_point();
                left_index = i;
            } else {
                // Right over left, insert left to path and restart scan from portal left point
                if path.is_empty() || portal_right != path[path.len() - 1] {
                    path.push(portal_right);
                }
                // Make current right the new apex
                portal_apex = portal_right;
                apex_index = right_index;
                // Reset portal
                portal_left = portal_apex;
                portal_right = portal_apex;
                left_index = apex_index;
                right_index = apex_index;
                // Restart scan
                i = apex_index + 1;
                continue;
            }
        }

        i += 1;
    }

    if path[path.len() - 1] != *to {
        path.push(*to);
    }

    path
}
