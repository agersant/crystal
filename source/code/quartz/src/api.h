#pragma once
#include "vector_math.h"

#define MAX_TRIANGLES 1000 // Update Lua FFI if changing this
#define MAX_EDGES ( 3 * MAX_TRIANGLES )
#define MAX_VERTICES ( 3 * MAX_TRIANGLES )

typedef struct QTriangle
{
	int vertices[3];
	int neighbours[3];
} QTriangle;

typedef struct QNavmesh
{
	int valid;
	int numTriangles;
	int numEdges;
	int numVertices;
	QVector vertices[MAX_VERTICES];
	QTriangle triangles[MAX_TRIANGLES];
} QNavmesh;

__declspec (dllexport) void ping();

__declspec ( dllexport ) void generateNavmesh( int numVertices, REAL vertices[], int numSegments, int segments[], int numHoles, REAL holes[], REAL padding, QNavmesh *outNavmesh );
