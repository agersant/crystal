#pragma once
#include "vector_math.h"

#define MAX_PATH_LENGTH 50

typedef struct BObstacle {
	int numVertices;
	BVector* vertices;
} BObstacle;

typedef struct BMap {
	int x;
	int y;
	int width;
	int height;
	BObstacle* obstacles;
	int numObstacles;
} BMap;

typedef struct BTriangle {
	int vertices[3];
	int neighbours[3];
	int connectedComponent;
	BVector center;
} BTriangle;

typedef struct BNavmesh {
	int numTriangles;
	int numVertices;
	BVector* vertices;
	BTriangle* triangles;
} BNavmesh;

typedef struct BPath {
	int numVertices;
	BVector* vertices;
} BPath;

#ifdef _MSC_VER
#define EXPORT __declspec(dllexport)
#endif

EXPORT void generateNavmesh(BMap* map, int padding, BNavmesh* outNavmesh);
EXPORT void planPath(const BNavmesh* navmesh, REAL startX, REAL startY, REAL endX, REAL endY,
					 BPath* outPath);
EXPORT BVector getNearestPointOnNavmesh(const BNavmesh* navmesh, REAL x, REAL y);

EXPORT void freeNavmesh(BNavmesh* navmesh);
EXPORT void freePath(BPath* path);
