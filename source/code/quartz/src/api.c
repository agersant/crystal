#include <assert.h>
#include "types.h"
#include "../../../../lib/triangle/triangle.h"
#include "api.h"
#include "quartz.h"

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
