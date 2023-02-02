use crate::extensions::*;
use crate::mesh::collision::CollisionMesh;
use crate::mesh::navigation::{NavigationMesh, Triangulation};
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;
use spade::delaunay::*;
use std::collections::HashSet;

#[derive(Debug)]
pub struct NavigationMeshBuilder {
    width: f32,
    height: f32,
    padding: f32,
}

impl NavigationMeshBuilder {
    pub fn new(width: f32, height: f32) -> Self {
        NavigationMeshBuilder {
            width,
            height,
            padding: 0.0,
        }
    }

    pub fn padding(mut self, padding: f32) -> Self {
        self.padding = padding.max(0.0);
        self
    }

    pub fn build(&self, collision_mesh: &CollisionMesh) -> NavigationMesh {
        type MP = geo_types::MultiPolygon<f32>;

        // Determine playable space
        let mut playable_space: MP = polygon![
            (x: self.padding, y: self.padding),
            (x: self.width - self.padding, y: self.padding),
            (x: self.width - self.padding, y: self.height - self.padding),
            (x: self.padding, y: self.height - self.padding)
        ]
        .into();

        for obstacle in &collision_mesh.obstacles.0 {
            let padded_obstacle = pad_obstacle(obstacle, self.padding);
            playable_space = playable_space.difference(&padded_obstacle);
        }

        // Triangulate
        let mut obstacle_edges = HashSet::new();
        let mut triangulation = FloatCDT::with_tree_locate();
        for polygon in &playable_space.0 {
            for line in polygon.exterior().lines() {
                let handle0 = triangulation.insert([line.start.x, line.start.y]);
                let handle1 = triangulation.insert([line.end.x, line.end.y]);
                if triangulation.can_add_constraint(handle0, handle1) {
                    triangulation.add_constraint(handle0, handle1);
                    if let Some(edge) = triangulation.get_edge_from_neighbors(handle0, handle1) {
                        obstacle_edges.insert(edge.fix());
                    }
                }
            }
            for interior in polygon.interiors() {
                for line in interior.lines() {
                    let handle0 = triangulation.insert([line.start.x, line.start.y]);
                    let handle1 = triangulation.insert([line.end.x, line.end.y]);
                    if triangulation.can_add_constraint(handle0, handle1) {
                        triangulation.add_constraint(handle0, handle1);
                        if let Some(edge) = triangulation.get_edge_from_neighbors(handle0, handle1)
                        {
                            obstacle_edges.insert(edge.sym().fix());
                        }
                    }
                }
            }
        }

        let navigable_faces = compute_navigable_faces(&triangulation, &obstacle_edges);

        NavigationMesh {
            triangulation,
            navigable_faces,
        }
    }
}

// This assumes that offset is small enough to not change the topology of the polygon (does not create self-intersection, merge interiors, etc.)
fn pad_obstacle(obstacle: &geo_types::Polygon<f32>, offset: f32) -> geo_types::Polygon<f32> {
    let padded_exterior = obstacle.exterior().offset(offset);
    let padded_interiors: Vec<LineString<f32>> = obstacle
        .interiors()
        .iter()
        .map(|interior| interior.offset(-offset))
        .collect();
    geo_types::Polygon::new(padded_exterior, padded_interiors)
}

// Based on https://github.com/Stoeoef/spade/issues/58
fn compute_navigable_faces(
    triangulation: &Triangulation,
    obstacle_edges: &HashSet<usize>,
) -> HashSet<usize> {
    let mut navigable_faces = HashSet::new();
    'face_loop: for face in triangulation.triangles() {
        if let Some(edge) = face.adjacent_edge() {
            for edge in edge.ccw_iter().skip(1) {
                let outgoing_obstacle = obstacle_edges.contains(&edge.fix());
                let incoming_obstacle = obstacle_edges.contains(&edge.sym().fix());
                if outgoing_obstacle != incoming_obstacle {
                    if incoming_obstacle {
                        navigable_faces.insert(face.fix());
                    }
                    continue 'face_loop;
                }
            }
        }
    }
    navigable_faces
}
