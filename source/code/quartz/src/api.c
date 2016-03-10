#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "api.h"
#include "../../../../lib/gpc/gpc.h"
#include "../../../../lib/triangle/triangle.h"

typedef struct triangulateio QTriangulation;

void ping()
{
	printf( "Pong!\n" );
}

static int isObstacleClockwise( const QObstacle *obstacle )
{
	REAL sum = 0;
	for ( int vertexIndex = 0; vertexIndex < obstacle->numVertices; vertexIndex++ )
	{
		QVector *vertexA = &obstacle->vertices[vertexIndex];
		QVector *vertexB = &obstacle->vertices[( vertexIndex + 1 ) % obstacle->numVertices];
		sum += ( vertexB->x - vertexA->x ) * ( vertexB->y + vertexA->y );
	}
	return sum > 0;
}

static void padMap( int padding, const QMap *inMap, QMap *outMap )
{
	*outMap = *inMap;

	outMap->x += padding;
	outMap->y += padding;
	outMap->width -= 2 * padding;
	outMap->height -= 2 * padding;
	outMap->obstacles = malloc( inMap->numObstacles * sizeof( QObstacle ) );

	for ( int obstacleIndex = 0; obstacleIndex < inMap->numObstacles; obstacleIndex++ )
	{
		const QObstacle *const inObstacle = &inMap->obstacles[obstacleIndex];
		const int numVertices = inObstacle->numVertices;
		assert( numVertices > 2 );
		const int isClockwise = isObstacleClockwise( inObstacle );

		QObstacle *const outObstacle = &outMap->obstacles[obstacleIndex];
		outObstacle->numVertices = inObstacle->numVertices;
		outObstacle->vertices = malloc( numVertices * sizeof( QVector ) );

		for ( int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++ )
		{
			QVector *const targetVertex = &outObstacle->vertices[vertexIndex];

			QEdge edgeA;
			QEdge edgeB;
			edgeA.start = inObstacle->vertices[( numVertices + vertexIndex - 1 ) % numVertices];
			edgeA.end = inObstacle->vertices[vertexIndex];
			edgeB.start = inObstacle->vertices[vertexIndex];
			edgeB.end = inObstacle->vertices[( vertexIndex + 1 ) % numVertices];

			QVector vectorA;
			QVector vectorB;
			edgeToVector( &edgeA, &vectorA );
			edgeToVector( &edgeB, &vectorB );

			if ( areVectorsColinear( &vectorA, &vectorB ) )
			{
				QVector paddingVector;
				vectorNormal( &vectorA, !isClockwise, &paddingVector );
				vectorNormalize( &paddingVector );
				vectorScale( &paddingVector, padding );
				vectorAdd( targetVertex, &paddingVector, targetVertex );
			}
			else
			{
				{
					QVector edgeNormal;
					vectorNormal( &vectorA, !isClockwise, &edgeNormal );
					vectorNormalize( &edgeNormal );
					vectorScale( &edgeNormal, padding );
					edgeOffset( &edgeA, &edgeNormal, &edgeA );
				}
				{
					QVector edgeNormal;
					vectorNormal( &vectorB, !isClockwise, &edgeNormal );
					vectorNormalize( &edgeNormal );
					vectorScale( &edgeNormal, padding );
					edgeOffset( &edgeB, &edgeNormal, &edgeB );
				}

				const int intersects = lineIntersection( &edgeA, &edgeB, targetVertex );
				assert( intersects );
			}
		}
	}
}

static void mapToPolygonWithHoles( const QMap *map, gpc_polygon *outMapPolygon )
{
	memset( outMapPolygon, 0, sizeof( *outMapPolygon ) );
	{
		gpc_vertex_list mapEdges;
		mapEdges.num_vertices = 4;
		mapEdges.vertex = malloc( 4 * sizeof( gpc_vertex ) );
		mapEdges.vertex[0].x = map->x;
		mapEdges.vertex[0].y = map->y;
		mapEdges.vertex[1].x = map->x + map->width;
		mapEdges.vertex[1].y = map->y;
		mapEdges.vertex[2].x = map->x + map->width;
		mapEdges.vertex[2].y = map->y + map->height;
		mapEdges.vertex[3].x = map->x;
		mapEdges.vertex[3].y = map->y + map->height;
		gpc_add_contour( outMapPolygon, &mapEdges, 0 );
		free( mapEdges.vertex );
	}

	for ( int obstacleIndex = 0; obstacleIndex < map->numObstacles; obstacleIndex++ )
	{
		const int numVertices = map->obstacles[obstacleIndex].numVertices;
		assert( numVertices > 2 );

		gpc_vertex_list *obstacleContour = malloc( sizeof( gpc_vertex_list ) );
		obstacleContour->num_vertices = numVertices;
		obstacleContour->vertex = malloc( numVertices * sizeof( gpc_vertex ) );
		for ( int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++ )
		{
			gpc_vertex *const vertex = &obstacleContour->vertex[vertexIndex];
			vertex->x = map->obstacles[obstacleIndex].vertices[vertexIndex].x;
			vertex->y = map->obstacles[obstacleIndex].vertices[vertexIndex].y;
		}

		gpc_polygon obstaclePolygon;
		obstaclePolygon.contour = obstacleContour;
		obstaclePolygon.num_contours = 1;
		obstaclePolygon.hole = malloc( sizeof( int ) );
		obstaclePolygon.hole[0] = 0;

		gpc_polygon_clip( GPC_DIFF, outMapPolygon, &obstaclePolygon, outMapPolygon );

		gpc_free_polygon( &obstaclePolygon );
	}
}

// TODO.optimization: This would be faster if we kept the array sorted
static int insertPointInTriangulationInput( REAL x, REAL y, QTriangulation *outTriangulation )
{
	for ( int i = 0; i < outTriangulation->numberofpoints; i++ )
	{
		const REAL *const point = &outTriangulation->pointlist[2 * i];
		if ( point[0] == x && point[1] == y )
		{
			return i;
		}
	}
	REAL *const point = &outTriangulation->pointlist[2 * outTriangulation->numberofpoints];
	point[0] = x;
	point[1] = y;
	outTriangulation->numberofpoints += 1;
	return outTriangulation->numberofpoints - 1;
}

static void getPointWithinContour( const gpc_vertex_list *contour, QVector *outPoint )
{
	const int numVertices = contour->num_vertices;
	assert( numVertices > 2 );

	// Find a x coordinate within the contour's bounding box
	// which is not the x coordinate of any of the vertices
	{
		REAL minX = DBL_MAX;
		REAL minX2 = DBL_MAX;
		for ( int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++ )
		{
			const gpc_vertex *const vertex = &contour->vertex[vertexIndex];
			if ( vertex->x < minX )
			{
				minX2 = minX;
				minX = vertex->x;
			}
		}
		assert( minX != DBL_MAX );
		assert( minX2 != DBL_MAX );
		assert( minX != minX2 );
		outPoint->x = ( minX + minX2 ) / 2;
	}
	
	// Intersect the vertical going through x with all segments in the contour
	// Keeping the lowest two y coordinates of intersections
	{
		QEdge vertical;
		vertical.start.x = outPoint->x;
		vertical.start.y = 0;
		vertical.end.x = outPoint->x;
		vertical.end.x = 1;
		for ( int vertexIndex = 1; vertexIndex <= numVertices; vertexIndex++ )
		{
			REAL minY = DBL_MAX;
			REAL minY2 = DBL_MAX;
			for ( int vertexIndex = 1; vertexIndex <= numVertices; vertexIndex++ )
			{
				const gpc_vertex *const previousVertex = &contour->vertex[vertexIndex - 1];
				const gpc_vertex *const vertex = &contour->vertex[vertexIndex % numVertices];
				assert( outPoint->x != previousVertex->x );
				assert( outPoint->x != vertex->x );
				
				if ( ( previousVertex->x - outPoint->x ) * ( vertex->x - outPoint->x ) >= 0 )
				{
					continue;
				}

				QEdge edge;
				edge.start.x = previousVertex->x;
				edge.start.y = previousVertex->y;
				edge.end.x = vertex->x;
				edge.end.y = vertex->y;

				QVector intersection;
				lineIntersection( &edge, &vertical, &intersection );
				if ( intersection.y < minY )
				{
					minY2 = minY;
					minY = intersection.y;
				}
			}
			assert( minY != DBL_MAX );
			assert( minY2 != DBL_MAX );
			assert( minY != minY2 );
			outPoint->y = ( minY + minY2 ) / 2;
		}
	}
}

static void triangulateMap( QMap *map, QTriangulation *outTriangulation )
{
	memset( outTriangulation, 0, sizeof( *outTriangulation ) );

	gpc_polygon mapPolygon;
	mapToPolygonWithHoles( map, &mapPolygon );

	QTriangulation triangulationInput;
	memset( &triangulationInput, 0, sizeof( triangulationInput ) );

	int maxPoints = 0;
	assert( mapPolygon.num_contours > 0 );
	for ( int contourIndex = 0; contourIndex < mapPolygon.num_contours; contourIndex++ )
	{
		const gpc_vertex_list *const contour = &mapPolygon.contour[contourIndex];
		assert( contour->num_vertices > 2 );
		maxPoints += contour->num_vertices;
		triangulationInput.numberofsegments += contour->num_vertices;
		if ( mapPolygon.hole[contourIndex] )
		{
			triangulationInput.numberofholes++;
		}
	}

	triangulationInput.pointlist = malloc( maxPoints * 2 * sizeof( REAL ) );
	triangulationInput.segmentlist = malloc( triangulationInput.numberofsegments * 2 * sizeof( int ) );
	triangulationInput.holelist = malloc( triangulationInput.numberofholes * 2 * sizeof( REAL ) );
	
	triangulationInput.numberofpoints = 0;
	int numSegments = 0;
	int numHoles = 0;
	for ( int contourIndex = 0; contourIndex < mapPolygon.num_contours; contourIndex++ )
	{
		const gpc_vertex_list *const contour = &mapPolygon.contour[contourIndex];
		const int numVertices = contour->num_vertices;
		assert( numVertices > 2 );
		for ( int vertexIndex = 0; vertexIndex <= numVertices; vertexIndex++ )
		{
			const gpc_vertex *const vertex = &contour->vertex[vertexIndex % numVertices];
			const int endPoint = insertPointInTriangulationInput( vertex->x, vertex->y, &triangulationInput );
			if ( vertexIndex > 0 )
			{
				const gpc_vertex *const previousVertex = &contour->vertex[vertexIndex - 1];
				const int startPoint = insertPointInTriangulationInput( previousVertex->x, previousVertex->y, &triangulationInput );
				int *const segment = &triangulationInput.segmentlist[2 * numSegments];
				segment[0] = startPoint;
				segment[1] = endPoint;
				numSegments++;
			}
		}
		if ( mapPolygon.hole[contourIndex] )
		{
			QVector holePoint;
			getPointWithinContour( contour, &holePoint );
			REAL *const hole = &triangulationInput.holelist[2 * numHoles];
			hole[0] = holePoint.x;
			hole[1] = holePoint.y;
			numHoles++;
		}
	}

	assert( numSegments == triangulationInput.numberofsegments );
	assert( numHoles == triangulationInput.numberofholes );

	triangulate( "pjenzq0V", &triangulationInput, outTriangulation, NULL );

	gpc_free_polygon( &mapPolygon );
}

static void triangulationToNavmesh( const struct triangulateio *triangleOutput, QNavmesh *outNavmesh )
{
	assert( outNavmesh );
	assert( triangleOutput );

	memset( outNavmesh, 0, sizeof( *outNavmesh ) );
	assert( triangleOutput->numberofpoints < MAX_VERTICES );
	assert( triangleOutput->numberoftriangles < MAX_TRIANGLES );

	outNavmesh->numVertices = triangleOutput->numberofpoints;
	outNavmesh->numEdges = triangleOutput->numberofedges;
	outNavmesh->numTriangles = triangleOutput->numberoftriangles;

	for ( int i = 0; i < outNavmesh->numVertices; i++ )
	{
		outNavmesh->vertices[i].x = triangleOutput->pointlist[2 * i + 0];
		outNavmesh->vertices[i].y = triangleOutput->pointlist[2 * i + 1];
	}

	for ( int i = 0; i < outNavmesh->numTriangles; i++ )
	{
		outNavmesh->triangles[i].vertices[0] = triangleOutput->trianglelist[3 * i + 0];
		outNavmesh->triangles[i].vertices[1] = triangleOutput->trianglelist[3 * i + 1];
		outNavmesh->triangles[i].vertices[2] = triangleOutput->trianglelist[3 * i + 2];
		outNavmesh->triangles[i].neighbours[0] = triangleOutput->neighborlist[3 * i + 0];
		outNavmesh->triangles[i].neighbours[1] = triangleOutput->neighborlist[3 * i + 1];
		outNavmesh->triangles[i].neighbours[2] = triangleOutput->neighborlist[3 * i + 2];
	}

	return;
}

static void freeMap( QMap *map )
{
	for ( int obstacleIndex = 0; obstacleIndex < map->numObstacles; obstacleIndex++ )
	{
		free( map->obstacles[obstacleIndex].vertices );
		map->obstacles[obstacleIndex].vertices = NULL;
	}
	free( map->obstacles );
	map->obstacles = NULL;
	free( map );
}

void generateNavmesh( QMap *map, int padding, QNavmesh *outNavmesh )
{
	assert( map->width > 0 );
	assert( map->height > 0 );

	QMap *paddedMap = malloc( sizeof( QMap ) );
	padMap( padding, map, paddedMap );

	QTriangulation triangulation;
	triangulateMap( paddedMap, &triangulation );

	triangulationToNavmesh( &triangulation, outNavmesh );
	
	freeMap( paddedMap );
	trifree( triangulation.pointlist );
	trifree( triangulation.pointmarkerlist );
	trifree( triangulation.trianglelist );
	trifree( triangulation.neighborlist );
	trifree( triangulation.segmentlist );
	trifree( triangulation.segmentmarkerlist );
	trifree( triangulation.edgelist );
	trifree( triangulation.edgemarkerlist );
}
