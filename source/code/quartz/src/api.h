#pragma once
#include "vector_math.h"

#define MAX_TRIANGLES 1000 // Update Lua FFI if changing this
#define MAX_VERTICES ( 3 * MAX_TRIANGLES )
#define MAX_PATH_LENGTH 50

typedef struct QObstacle
{
	int numVertices;
	QVector *vertices;
} QObstacle;

typedef struct QMap
{
	int x;
	int y;
	int width;
	int height;
	QObstacle *obstacles;
	int numObstacles;
} QMap;

typedef struct QTriangle
{
	int vertices[3];
	int neighbours[3];
} QTriangle;

typedef struct QNavmesh
{
	int numTriangles;
	int numEdges;
	int numVertices;
	QVector vertices[MAX_VERTICES];
	QTriangle triangles[MAX_TRIANGLES];
} QNavmesh;

typedef struct QPath
{
	int numPoints;
	QVector points[MAX_PATH_LENGTH];
} QPath;

__declspec ( dllexport ) void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh );
__declspec ( dllexport ) void planPath( const QNavmesh *navmesh, REAL startX, REAL startY, REAL endX, REAL endY, QPath *outPath );
