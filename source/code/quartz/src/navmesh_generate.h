#pragma once
#include "types.h"
#include "../../../../lib/gpc/gpc.h"
#include "../../../../lib/triangle/triangle.h"

typedef struct triangulateio QTriangulation;

typedef struct QPolygonMap
{
	int x;
	int y;
	int width;
	int height;
	gpc_polygon *polygons;
	int numPolygons;
} QPolygonMap;

void mapToPolygonMap( const QMap *map, QPolygonMap *outPolygonMap );
void padPolygonMap( int padding, const QPolygonMap *inMap, QPolygonMap *outMap );
void polygonMapToTriangulation( QPolygonMap *map, QTriangulation *outTriangulation );
void triangulationToNavmesh( const struct triangulateio *triangleOutput, QNavmesh *outNavmesh );
void freePolygonMap( QPolygonMap *map );
