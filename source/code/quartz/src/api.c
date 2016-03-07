#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "api.h"
#include "../../../../lib/triangle/triangle.h"

void ping()
{
	printf( "Pong!\n" );
}

typedef struct VertexLinks
{
	int numEdges;
	int numBoundaryEdges;
	int numTriangles;
	int *edges;			// Indices into triangleOutput->edgelist
	int *boundaryEdges; // Indices into *edges
	int *triangles;		// Indices into triangleOutput->trianglelist
	int curNumEdges;
	int curNumBoundaryEdges;
	int curNumTriangles;
} VertexLinks;


void getVertex( const struct triangulateio *triangleOutput, int vertex, Vector *out )
{
	out->x = triangleOutput->pointlist[2 * vertex];
	out->y = triangleOutput->pointlist[2 * vertex + 1];
}

void getEdge( const struct triangulateio *triangleOutput, int edge, Edge *out )
{
	getVertex( triangleOutput, triangleOutput->edgelist[2 * edge], &out->start );
	getVertex( triangleOutput, triangleOutput->edgelist[2 * edge + 1], &out->end );
}

void populateVerticesLinks( const struct triangulateio *triangleOutput, VertexLinks verticesLinks[] )
{
	memset( verticesLinks, 0, sizeof( VertexLinks ) * triangleOutput->numberofpoints );

	// Count edges touching each vertex
	for ( int i = 0; i < triangleOutput->numberofedges; i++ )
	{
		const int startVertex = triangleOutput->edgelist[2 * i];
		const int endVertex = triangleOutput->edgelist[2 * i + 1];
		verticesLinks[startVertex].numEdges++;
		verticesLinks[endVertex].numEdges++;
		if ( triangleOutput->edgemarkerlist[i] )
		{
			verticesLinks[startVertex].numBoundaryEdges++;
			verticesLinks[endVertex].numBoundaryEdges++;
		}
	}

	// Count triangles touching each vertex
	for ( int i = 0; i < triangleOutput->numberoftriangles; i++ )
	{
		const int vertexA = triangleOutput->trianglelist[3 * i];
		const int vertexB = triangleOutput->trianglelist[3 * i + 1];
		const int vertexC = triangleOutput->trianglelist[3 * i + 2];
		verticesLinks[vertexA].numTriangles++;
		verticesLinks[vertexB].numTriangles++;
		verticesLinks[vertexC].numTriangles++;
	}

	// Allocate memory to store which edges touch which vertex
	for ( int i = 0; i < triangleOutput->numberofpoints; i++ )
	{
		if ( verticesLinks[i].numEdges > 0 )
		{
			verticesLinks[i].edges = malloc( sizeof( int ) * verticesLinks[i].numEdges );
		}
		if ( verticesLinks[i].numBoundaryEdges > 0 )
		{
			verticesLinks[i].boundaryEdges = malloc( sizeof( int ) * verticesLinks[i].numBoundaryEdges );
		}
		if ( verticesLinks[i].numTriangles > 0 )
		{
			verticesLinks[i].triangles = malloc( sizeof( int ) * verticesLinks[i].numTriangles );
		}
	}

	// Store which edges touch each vertex
	for ( int i = 0; i < triangleOutput->numberofedges; i++ )
	{
		for ( int j = 0; j < 2; j++ )
		{
			VertexLinks *const vertexLinks = &verticesLinks[triangleOutput->edgelist[2 * i + j]];
			assert( vertexLinks->curNumEdges < vertexLinks->numEdges );
			vertexLinks->edges[vertexLinks->curNumEdges] = i;
			if ( triangleOutput->edgemarkerlist[i] )
			{
				assert( vertexLinks->curNumBoundaryEdges < vertexLinks->numBoundaryEdges );
				vertexLinks->boundaryEdges[vertexLinks->curNumBoundaryEdges] = vertexLinks->curNumEdges;
				vertexLinks->curNumBoundaryEdges++;
			}
			vertexLinks->curNumEdges++;
		}
	}

	// Store which triangle touch each vertex
	for ( int i = 0; i < triangleOutput->numberoftriangles; i++ )
	{
		for ( int j = 0; j < 3; j++ )
		{
			VertexLinks *const vertexLinks = &verticesLinks[triangleOutput->trianglelist[3 * i + j]];
			assert( vertexLinks->curNumTriangles < vertexLinks->numTriangles );
			vertexLinks->triangles[vertexLinks->curNumTriangles] = i;
			vertexLinks->curNumTriangles++;
		}
	}
}

void padNavmesh( const Navmesh *in, const struct triangulateio *triangleOutput, Navmesh *out, REAL padding )
{
	assert( in );
	assert( out );
	assert( in != out );
	assert( padding >= 0 );
	assert( in->valid );

	*out = *in;

	if ( padding == 0 )
	{
		return;
	}

	// Terminology: "edge" means any edge in the output, "segment" means constrained-edge (ie. part of the obstacles or map boundaries)
	const int numVertices = triangleOutput->numberofpoints;
	VertexLinks *verticesLinks = malloc( sizeof( VertexLinks ) * numVertices );
	populateVerticesLinks( triangleOutput, verticesLinks );

	// Move vertices!
	for ( int i = 0; i < numVertices; i++ )
	{
		Vector vertex;
		VertexLinks *vertexLinks = &verticesLinks[i];
		getVertex( triangleOutput, i, &vertex );

		assert( vertexLinks->curNumEdges == vertexLinks->numEdges );
		assert( vertexLinks->curNumBoundaryEdges == vertexLinks->numBoundaryEdges );
		assert( vertexLinks->curNumTriangles == vertexLinks->numTriangles );

		// Ignore non boundary vertices
		if ( vertexLinks->numBoundaryEdges == 0 )
		{
			assert( !triangleOutput->pointmarkerlist[i] ); // TODO figure out why this hits
			continue;
		}

		assert( vertexLinks->numBoundaryEdges % 2 == 0 ); // TODO figure out why this hits

		if ( vertexLinks->numBoundaryEdges == 2 )
		{
			Edge edgeA;
			Edge edgeB;
			getEdge( triangleOutput, vertexLinks->edges[vertexLinks->boundaryEdges[0]], &edgeA );
			getEdge( triangleOutput, vertexLinks->edges[vertexLinks->boundaryEdges[1]], &edgeB );
			
			if ( !vectorEquals( &edgeA.start, &vertex ) )
			{
				flipEdge( &edgeA );
				assert( vectorEquals( &edgeA.start, &vertex ) );
			}

			if ( !vectorEquals( &edgeB.start, &vertex ) )
			{
				flipEdge( &edgeB );
				assert( vectorEquals( &edgeB.start, &vertex ) );
			}

			Vector movedVertex;
			getPushedVector( &edgeA, &edgeB, padding, &movedVertex );
			out->vertices[i] = movedVertex;

		} // else todo
	}

	// Cleanup
	for ( int i = 0; i < numVertices; i++ )
	{
		if ( verticesLinks[i].numEdges > 0 )
		{
			free( verticesLinks[i].edges );
		}
		if ( verticesLinks[i].numBoundaryEdges > 0 )
		{
			free( verticesLinks[i].boundaryEdges );
		}
	}
	free( verticesLinks );

}

void populateNavmesh( Navmesh *navmesh, const struct triangulateio *triangleOutput )
{
	assert( navmesh );
	assert( triangleOutput );

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

void generateNavmesh( int numVertices, REAL vertices[], int numSegments, int segments[], int numHoles, REAL holes[], REAL padding, Navmesh *outNavmesh )
{
	assert( numVertices >= 0 );
	assert( numSegments >= 0 );
	assert( numHoles >= 0 );
	assert( vertices );
	assert( segments );
	assert( holes );

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
	// TODO. Investigate why test map output as 5 points more than input while only 2 extra-points are visible in the navmesh

	Navmesh *navmesh = malloc( sizeof( Navmesh ) );
	populateNavmesh( navmesh, &triangleOutput );

	padNavmesh( navmesh, &triangleOutput, outNavmesh, padding );
	free( navmesh );

	trifree( triangleOutput.pointlist );
	trifree( triangleOutput.pointmarkerlist );
	trifree( triangleOutput.trianglelist );
	trifree( triangleOutput.neighborlist );
	trifree( triangleOutput.segmentlist );
	trifree( triangleOutput.segmentmarkerlist );
	trifree( triangleOutput.edgelist );
	trifree( triangleOutput.edgemarkerlist );
}
