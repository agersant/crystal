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

struct Navmesh generateNavmesh( int numVertices, REAL vertices[], int numSegments, int segments[], int numHoles, REAL holes[] )
{
	struct triangulateio triangleInput;
	struct triangulateio triangleOutput;
	memset( &triangleInput, 0, sizeof( triangleInput ) );
	memset( &triangleOutput, 0, sizeof( triangleOutput ) );
	
	triangleInput.numberofpoints = numVertices;
	triangleInput.pointlist = vertices;
	triangleInput.numberofsegments = numSegments;
	triangleInput.segmentlist = segments;
	triangleInput.holelist = holes;
	triangleInput.numberofholes = numHoles;
	
	triangulate( "pjenzq10V", &triangleInput, &triangleOutput, NULL );

	assert( holes == triangleOutput.holelist );
	assert( triangleOutput.numberofcorners == 3 );

	struct Navmesh navmesh;
	populateNavmesh( &navmesh, &triangleOutput );

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
