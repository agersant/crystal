#include <assert.h>
#include <stdio.h>
#include "navmesh_query.h"

typedef struct QPathfinderNode
{
	float cost;
	QVector position;
	int triangle;
} QPathfinderNode;

int findTriangleContainingPoint( const QNavmesh *navmesh, const QVector *point )
{
	assert( navmesh->numTriangles >= 0 );
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		const QVector *vertexA = &navmesh->vertices[navmesh->triangles[triangleIndex].vertices[0]];
		const QVector *vertexB = &navmesh->vertices[navmesh->triangles[triangleIndex].vertices[1]];
		const QVector *vertexC = &navmesh->vertices[navmesh->triangles[triangleIndex].vertices[2]];
		if ( doesTriangleContainPoint( vertexA, vertexB, vertexC, point ) )
		{
			return triangleIndex;
		}
	}
	return -1;
}

void pathfinder( const QNavmesh *navmesh, const QVector *start, const QVector *end, QPath *outPath )
{
	assert( outPath->numVertices == 0 );
	const int startTriangle = findTriangleContainingPoint( navmesh, start );
	const int endTriangle = findTriangleContainingPoint( navmesh, end );
	if ( startTriangle < 0 || endTriangle < 0 )
	{
		// TODO Return a decent path if start/end isn't on navmesh
		return;
	}

	printf( "Pathfinding from triangle %d to %d\n", startTriangle, endTriangle );

}