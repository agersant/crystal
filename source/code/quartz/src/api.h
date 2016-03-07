#pragma once
#include "vector_math.h"

#define MAX_TRIANGLES 1000 // Update Lua FFI if changing this
#define MAX_EDGES ( 3 * MAX_TRIANGLES )
#define MAX_VERTICES ( 3 * MAX_TRIANGLES )

typedef struct Triangle
{
	int vertices[3];
	int neighbours[3];
} Triangle;

typedef struct Navmesh
{
	int valid;
	int numTriangles;
	int numEdges;
	int numVertices;
	Vector vertices[MAX_VERTICES];
	Triangle triangles[MAX_TRIANGLES];
} Navmesh;

__declspec (dllexport) void ping();

__declspec ( dllexport ) void generateNavmesh( int numVertices, REAL vertices[], int numSegments, int segments[], int numHoles, REAL holes[], REAL padding, Navmesh *outNavmesh );
