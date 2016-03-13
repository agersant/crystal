#pragma once
#include "vector_math.h"

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
	QVector center;
} QTriangle;

typedef struct QNavmesh
{
	int numTriangles;
	int numVertices;
	QVector *vertices;
	QTriangle *triangles;
} QNavmesh;

typedef struct QPath
{
	int numVertices;
	QVector *vertices;
} QPath;

__declspec ( dllexport ) void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh );
__declspec ( dllexport ) void planPath( const QNavmesh *navmesh, REAL startX, REAL startY, REAL endX, REAL endY, QPath *outPath );

__declspec ( dllexport ) void freeNavmesh( QNavmesh *navmesh );
__declspec ( dllexport ) void freePath( QPath *path );
