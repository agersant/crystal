#pragma once

#define MAX_TRIANGLES 1000 // Update Lua FFI if changing this
#define MAX_EDGES ( 3 * MAX_TRIANGLES )
#define MAX_VERTICES ( 3 * MAX_TRIANGLES )

#ifdef SINGLE // Update Lua FFI if changing this
#define REAL float
#else /* not SINGLE */
#define REAL double
#endif /* not SINGLE */

struct Vertex
{
	REAL x;
	REAL y;
};

struct Triangle
{
	int vertices[3];
	int neighbours[3];
};

struct Navmesh
{
	int valid;
	int numTriangles;
	int numEdges;
	int numVertices;
	struct Vertex vertices[MAX_VERTICES];
	struct Triangle triangles[MAX_TRIANGLES];
};

__declspec (dllexport) void ping();

__declspec ( dllexport ) struct Navmesh generateNavmesh( double mapWidth, double mapHeight );
