#pragma once
#include "api.h"
#include "types.h"

#include "../../../../lib/gpc/gpc.h"
#include "../../../../lib/triangle/triangle.h"

typedef struct triangulateio BTriangulation;

typedef struct BPolygonMap {
	int x;
	int y;
	int width;
	int height;
	gpc_polygon* polygons;
	int numPolygons;
} BPolygonMap;

void mapToPolygonMap(const BMap* map, BPolygonMap* outPolygonMap);
void padPolygonMap(int padding, const BPolygonMap* inMap, BPolygonMap* outMap);
void polygonMapToTriangulation(BPolygonMap* map, BTriangulation* outTriangulation);
void triangulationToNavmesh(const BTriangulation* triangleOutput, BNavmesh* outNavmesh);
void freePolygonMap(BPolygonMap* map);
