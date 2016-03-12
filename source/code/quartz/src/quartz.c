#include <assert.h>
#include <float.h>
#include <stdlib.h>
#include <string.h>
#include "api.h"
#include "quartz.h"
#include "types.h"
#include "vector_math.h"



//INTERNALS

static int isContourClockwise( const gpc_vertex_list *contour )
{
	REAL sum = 0;
	for ( int vertexIndex = 0; vertexIndex < contour->num_vertices; vertexIndex++ )
	{
		const gpc_vertex *const vertexA = &contour->vertex[vertexIndex];
		const gpc_vertex *const vertexB = &contour->vertex[( vertexIndex + 1 ) % contour->num_vertices];
		sum += ( vertexB->x - vertexA->x ) * ( vertexB->y + vertexA->y );
	}
	return sum > 0;
}

static void padVertex( const QEdge *inEdgeA, const QEdge *inEdgeB, int clockwise, REAL padding, QVector *outPaddedVertex )
{
	QEdge edgeA, edgeB;
	edgeA = *inEdgeA;
	edgeB = *inEdgeB;
	assert( vectorEquals( &edgeA.end, &edgeB.start ) );

	QVector vectorA;
	QVector vectorB;
	edgeToVector( &edgeA, &vectorA );
	edgeToVector( &edgeB, &vectorB );

	*outPaddedVertex = edgeA.end;

	if ( areVectorsColinear( &vectorA, &vectorB ) )
	{
		QVector paddingVector;
		vectorNormal( &vectorA, !clockwise, &paddingVector );
		vectorNormalize( &paddingVector );
		vectorScale( &paddingVector, padding );
		vectorAdd( outPaddedVertex, &paddingVector, outPaddedVertex );
	}
	else
	{
		{
			QVector edgeNormal;
			vectorNormal( &vectorA, !clockwise, &edgeNormal );
			vectorNormalize( &edgeNormal );
			vectorScale( &edgeNormal, padding );
			edgeOffset( &edgeA, &edgeNormal, &edgeA );
		}
		{
			QVector edgeNormal;
			vectorNormal( &vectorB, !clockwise, &edgeNormal );
			vectorNormalize( &edgeNormal );
			vectorScale( &edgeNormal, padding );
			edgeOffset( &edgeB, &edgeNormal, &edgeB );
		}

		verify( lineIntersection( &edgeA, &edgeB, outPaddedVertex ) );
	}
}

static void makeQuadrilateralPolygon( QVector *cornerA, QVector *cornerB, QVector *cornerC, QVector *cornerD, gpc_polygon *outPolygon )
{
	outPolygon->num_contours = 1;
	outPolygon->contour = malloc( sizeof( gpc_vertex_list ) );
	outPolygon->hole = malloc( sizeof( int ) );
	outPolygon->hole[0] = 0;
	outPolygon->contour[0].num_vertices = 4;
	outPolygon->contour[0].vertex = malloc( 4 * sizeof( gpc_vertex ) );
	outPolygon->contour[0].vertex[0].x = cornerA->x;
	outPolygon->contour[0].vertex[0].y = cornerA->y;
	outPolygon->contour[0].vertex[1].x = cornerB->x;
	outPolygon->contour[0].vertex[1].y = cornerB->y;
	outPolygon->contour[0].vertex[2].x = cornerC->x;
	outPolygon->contour[0].vertex[2].y = cornerC->y;
	outPolygon->contour[0].vertex[3].x = cornerD->x;
	outPolygon->contour[0].vertex[3].y = cornerD->y;
}

static int insertPointInTriangulationInput( REAL x, REAL y, QTriangulation *outTriangulation )
{
	// TODO.optimization: This would be faster if we kept the array sorted
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
			else if ( vertex->x != minX && vertex->x < minX2 )
			{
				minX2 = vertex->x;
			}
		}
		assert( minX != DBL_MAX );
		assert( minX2 != DBL_MAX );
		assert( minX < minX2 );
		outPoint->x = ( minX + minX2 ) / 2;
	}

	// Intersect the vertical going through x with all segments in the contour
	// Keeping the lowest two y coordinates of intersections
	{
		QEdge vertical;
		vertical.start.x = outPoint->x;
		vertical.start.y = 0;
		vertical.end.x = outPoint->x;
		vertical.end.y = 1;
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
				verify( lineIntersection( &edge, &vertical, &intersection ) );

				if ( intersection.y < minY )
				{
					minY2 = minY;
					minY = intersection.y;
				}
				else if ( intersection.y != minY && intersection.y < minY2 )
				{
					minY2 = intersection.y;
				}
			}
			assert( minY != DBL_MAX );
			assert( minY2 != DBL_MAX );
			assert( minY < minY2 );
			// If our obstacles had no holes, we would just use ( minY + minY2 ) / 2.
			// Since going so far away from the edge may put us in the middle of a hole,
			// We make the bet that our obstacle is at least QUARTZ_EPSILON big.
			outPoint->y = minY + min( QUARTZ_EPSILON, ( minY + minY2 ) / 2 );
		}
	}
}



// PUBLIC API

void mapToPolygonMap( const QMap *map, QPolygonMap *outPolygonMap )
{
	memset( outPolygonMap, 0, sizeof( *outPolygonMap ) );
	outPolygonMap->x = map->x;
	outPolygonMap->y = map->y;
	outPolygonMap->width = map->width;
	outPolygonMap->height = map->height;
	outPolygonMap->numPolygons = map->numObstacles;
	outPolygonMap->polygons = malloc( outPolygonMap->numPolygons * sizeof( gpc_polygon ) );

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

		gpc_polygon *obstaclePolygon = &outPolygonMap->polygons[obstacleIndex];
		obstaclePolygon->contour = obstacleContour;
		obstaclePolygon->num_contours = 1;
		obstaclePolygon->hole = malloc( sizeof( int ) );
		obstaclePolygon->hole[0] = 0;
	}
}

void padPolygonMap( int padding, const QPolygonMap *inMap, QPolygonMap *outMap )
{
	assert( inMap != outMap );

	memset( outMap, 0, sizeof( *outMap ) );
	outMap->x = inMap->x + padding;
	outMap->y = inMap->y + padding;
	outMap->width = inMap->width - 2 * padding;
	outMap->height = inMap->height - 2 * padding;
	outMap->numPolygons = inMap->numPolygons;
	outMap->polygons = malloc( inMap->numPolygons * sizeof( gpc_polygon ) );
	memset( outMap->polygons, 0, inMap->numPolygons * sizeof( gpc_polygon ) );

	for ( int polygonIndex = 0; polygonIndex < inMap->numPolygons; polygonIndex++ )
	{
		gpc_polygon *const inPolygon = &inMap->polygons[polygonIndex];
		gpc_polygon *const outPolygon = &outMap->polygons[polygonIndex];
		gpc_polygon_clip( GPC_UNION, outPolygon, inPolygon, outPolygon );

		for ( int contourIndex = 0; contourIndex < inPolygon->num_contours; contourIndex++ )
		{
			const gpc_vertex_list *const inContour = &inPolygon->contour[contourIndex];
			const int numVertices = inContour->num_vertices;
			assert( numVertices > 2 );
			int isClockwise = isContourClockwise( inContour );
			if ( inPolygon->hole[contourIndex] )
			{
				isClockwise = !isClockwise;
			}

			for ( int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++ )
			{
				QEdge edgeA, edgeB, edgeC;
				edgeA.start.x = inContour->vertex[vertexIndex].x;
				edgeA.start.y = inContour->vertex[vertexIndex].y;
				edgeA.end.x = inContour->vertex[( vertexIndex + 1 ) % numVertices].x;
				edgeA.end.y = inContour->vertex[( vertexIndex + 1 ) % numVertices].y;
				edgeB.start = edgeA.end;
				edgeB.end.x = inContour->vertex[( vertexIndex + 2 ) % numVertices].x;
				edgeB.end.y = inContour->vertex[( vertexIndex + 2 ) % numVertices].y;
				edgeC.start = edgeB.end;
				edgeC.end.x = inContour->vertex[( vertexIndex + 3 ) % numVertices].x;
				edgeC.end.y = inContour->vertex[( vertexIndex + 3 ) % numVertices].y;

				QEdge paddedEdgeB;
				padVertex( &edgeA, &edgeB, isClockwise, padding, &paddedEdgeB.start );
				padVertex( &edgeB, &edgeC, isClockwise, padding, &paddedEdgeB.end );

				gpc_polygon paddingPolygon;
				makeQuadrilateralPolygon( &edgeB.start, &paddedEdgeB.start, &paddedEdgeB.end, &edgeB.end, &paddingPolygon );

				gpc_polygon_clip( GPC_UNION, outPolygon, &paddingPolygon, outPolygon );

				gpc_free_polygon( &paddingPolygon );
			}

		}
	}
}

void polygonMapToTriangulation( QPolygonMap *map, QTriangulation *outTriangulation )
{
	memset( outTriangulation, 0, sizeof( *outTriangulation ) );

	QTriangulation triangulationInput;
	memset( &triangulationInput, 0, sizeof( triangulationInput ) );

	gpc_polygon mapPolygon;
	QVector topLeft, topRight, bottomRight, bottomLeft;
	topLeft.x = map->x;
	topLeft.y = map->y;
	topRight.x = map->x + map->width;
	topRight.y = map->y;
	bottomRight.x = map->x + map->width;
	bottomRight.y = map->y + map->height;
	bottomLeft.x = map->x;
	bottomLeft.y = map->y + map->height;
	makeQuadrilateralPolygon( &topLeft, &topRight, &bottomRight, &bottomLeft, &mapPolygon );

	for ( int obstacleIndex = 0; obstacleIndex < map->numPolygons; obstacleIndex++ )
	{
		gpc_polygon_clip( GPC_DIFF, &mapPolygon, &map->polygons[obstacleIndex], &mapPolygon );
	}

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

	triangulate( "pjenzq5Q", &triangulationInput, outTriangulation, NULL );

	trifree( triangulationInput.pointlist );
	trifree( triangulationInput.segmentlist );
	trifree( triangulationInput.holelist );

	gpc_free_polygon( &mapPolygon );
}

void triangulationToNavmesh( const struct triangulateio *triangleOutput, QNavmesh *outNavmesh )
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

void freePolygonMap( QPolygonMap *map )
{
	for ( int polygonIndex = 0; polygonIndex < map->numPolygons; polygonIndex++ )
	{
		gpc_free_polygon( &map->polygons[polygonIndex] );
	}
	free( map->polygons );
	map->polygons = NULL;
}
