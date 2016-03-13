#include <assert.h>
#include <stdlib.h>
#include "types.h"
#include "../../../../lib/triangle/triangle.h"
#include "api.h"
#include "navmesh_generate.h"
#include "navmesh_query.h"

void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh )
{
	assert( map->width > 0 );
	assert( map->height > 0 );

	QPolygonMap polygonMap;
	mapToPolygonMap( map, &polygonMap );

	QPolygonMap paddedMap;
	padPolygonMap( padding, &polygonMap, &paddedMap );

	QTriangulation triangulation;
	polygonMapToTriangulation( &paddedMap, &triangulation );

	triangulationToNavmesh( &triangulation, outNavmesh );
	
	freePolygonMap( &polygonMap );
	freePolygonMap( &paddedMap );
	trifree( triangulation.pointlist );
	trifree( triangulation.pointmarkerlist );
	trifree( triangulation.trianglelist );
	trifree( triangulation.neighborlist );
	trifree( triangulation.segmentlist );
	trifree( triangulation.segmentmarkerlist );
	trifree( triangulation.edgelist );
	trifree( triangulation.edgemarkerlist );
}

void planPath( const QNavmesh *navmesh, REAL startX, REAL startY, REAL endX, REAL endY, QPath *outPath )
{
	QVector start, end;
	start.x = startX;
	start.y = startY;
	end.x = endX;
	end.y = endY;
	pathfinder( navmesh, &start, &end, outPath );
}

void freeNavmesh( QNavmesh *navmesh )
{
	for ( int vertexIndex = 0; vertexIndex < navmesh->numVertices; vertexIndex++ )
	{
		free( &navmesh->vertices[vertexIndex] );
	}
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		free( &navmesh->triangles[triangleIndex] );
	}
}

void freePath( QPath *path )
{
	for ( int vertexIndex = 0; vertexIndex < path->numVertices; vertexIndex++ )
	{
		free( &path->vertices[vertexIndex] );
	}
}