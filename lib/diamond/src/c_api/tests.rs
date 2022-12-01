use crate::c_api::builder::*;
use crate::c_api::geometry::*;
use crate::c_api::mesh::*;
use std::slice;

#[test]
fn build_and_query_mesh() {
	unsafe {
		let builder = mesh_builder_new(10, 10, 16, 16, 0.0);

		let mut vertices = vec![
			CVertex { x: 64.0, y: 32.0 },
			CVertex { x: 80.0, y: 32.0 },
			CVertex { x: 80.0, y: 48.0 },
			CVertex { x: 64.0, y: 48.0 },
		];
		mesh_builder_add_polygon(builder, 4, 2, vertices.as_mut_ptr(), vertices.len() as i32);

		let mesh = mesh_new();
		mesh_builder_build_mesh(builder, mesh);
		mesh_builder_delete(builder);

		assert!(!(*mesh).collision.get_contours().is_empty());
		assert!(!(*mesh).navigation.get_triangles().is_empty());

		let nearest = mesh_get_nearest_navigable_point(mesh, 65.0, 40.0);
		assert_eq!(nearest.x, 64.0);
		assert_eq!(nearest.y, 40.0);

		let path = polygon_new();
		assert!(mesh_plan_path(mesh, 0.0, 0.0, 20.0, 20.0, path));
		assert_eq!((*path).num_vertices, 2);
		let path_vertices: &[CVertex] =
			slice::from_raw_parts((*path).vertices, (*path).num_vertices as usize);
		assert_eq!(path_vertices[0], CVertex { x: 0.0, y: 0.0 });
		assert_eq!(path_vertices[1], CVertex { x: 20.0, y: 20.0 });
		polygon_delete(path);

		let polygons = polygons_new();
		mesh_list_collision_polygons(mesh, polygons);
		assert_eq!((*polygons).num_polygons, 1);
		polygons_delete(polygons);

		let polygons = polygons_new();
		mesh_list_navigation_polygons(mesh, polygons);
		assert_eq!((*polygons).num_polygons, 8);
		polygons_delete(polygons);

		mesh_delete(mesh);
	}
}
