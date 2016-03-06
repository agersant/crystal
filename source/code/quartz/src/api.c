#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "api.h"
#include "../../../../lib/triangle/triangle.h"

void ping()
{
	printf( "Pong!\n" );
}

void populateNavmesh( struct Navmesh *navmesh, struct triangulateio *triangleOutput )
{
	memset( navmesh, 0, sizeof( *navmesh ) );
	if ( triangleOutput->numberofpoints > MAX_VERTICES )
	{
		return;
	}
	if ( triangleOutput->numberofedges > MAX_EDGES )
	{
		return;
	}
	if ( triangleOutput->numberoftriangles > MAX_TRIANGLES )
	{
		return;
	}

	navmesh->valid = 1;
	navmesh->numVertices = triangleOutput->numberofpoints;
	navmesh->numEdges = triangleOutput->numberofedges;
	navmesh->numTriangles = triangleOutput->numberoftriangles;

	for ( int i = 0; i < navmesh->numVertices; i++ )
	{
		navmesh->vertices[i].x = triangleOutput->pointlist[2 * i];
		navmesh->vertices[i].y = triangleOutput->pointlist[2 * i + 1];
	}

	for ( int i = 0; i < navmesh->numTriangles; i++ )
	{
		navmesh->triangles[i].vertices[0] = triangleOutput->trianglelist[3 * i];
		navmesh->triangles[i].vertices[1] = triangleOutput->trianglelist[3 * i + 1];
		navmesh->triangles[i].vertices[2] = triangleOutput->trianglelist[3 * i + 2];
		navmesh->triangles[i].neighbours[0] = triangleOutput->neighborlist[3 * i];
		navmesh->triangles[i].neighbours[1] = triangleOutput->neighborlist[3 * i + 1];
		navmesh->triangles[i].neighbours[2] = triangleOutput->neighborlist[3 * i + 2];
	}

	return;
}

struct Navmesh generateNavmesh( double mapWidth, double mapHeight )
{
	printf( "Triangulating map of size: %f, %f\n", mapWidth, mapHeight );

	struct triangulateio triangleInput;
	struct triangulateio triangleOutput;
	memset( &triangleInput, 0, sizeof( triangleInput ) );
	memset( &triangleOutput, 0, sizeof( triangleOutput ) );
	
	const int numPoints = 4; // TODO
	const int numSegments = 4; // TODO
	const int numHoles = 0; // TODO

	REAL *pointList = malloc( sizeof( REAL ) * 2 * numPoints ); // TODO populate
	int *segmentList = malloc( sizeof( int ) * 2 * numSegments ); // TODO populate
	REAL *holeList = malloc( sizeof( REAL ) * 2 * numHoles ); // TODO populate

	pointList[0] = 0;
	pointList[1] = 0;

	pointList[2] = 1;
	pointList[3] = 0;

	pointList[4] = 1;
	pointList[5] = 1;

	pointList[6] = 0;
	pointList[7] = 1;

	segmentList[0] = 0;
	segmentList[1] = 1;

	segmentList[2] = 1;
	segmentList[3] = 2;

	segmentList[4] = 2;
	segmentList[5] = 3;

	segmentList[6] = 3;
	segmentList[7] = 0;

	triangleInput.numberofpoints = numPoints;
	triangleInput.pointlist = pointList;
	triangleInput.numberofsegments = numSegments;
	triangleInput.segmentlist = segmentList;
	triangleInput.holelist = holeList;
	triangleInput.numberofholes = numHoles;
	
	triangulate( "pjenzYYV", &triangleInput, &triangleOutput, NULL );

	assert( holeList == triangleOutput.holelist );
	assert( triangleOutput.numberofcorners == 3 );

	struct Navmesh navmesh;
	populateNavmesh( &navmesh, &triangleOutput );

	free( pointList );
	free( segmentList );
	free( holeList );

	trifree( triangleOutput.pointlist );
	trifree( triangleOutput.pointmarkerlist );
	trifree( triangleOutput.trianglelist );
	trifree( triangleOutput.neighborlist );
	trifree( triangleOutput.segmentlist );
	trifree( triangleOutput.segmentmarkerlist );
	trifree( triangleOutput.edgelist );
	trifree( triangleOutput.edgemarkerlist );

	return navmesh;
}
