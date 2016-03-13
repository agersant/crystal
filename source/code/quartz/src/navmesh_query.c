#include <assert.h>
#include <stdio.h>
#include "linked_list.h"
#include "navmesh_query.h"

typedef struct QPathfinderNode
{
	float cost;
	float heuristic;
	int triangle;
	int previousTriangle;
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

static float movementCost( const QNavmesh *navmesh, int triangleA, int triangleB )
{
	assert( triangleA != triangleB );
	assert( triangleA >= 0 );
	assert( triangleB >= 0 );
	assert( triangleA < navmesh->numTriangles );
	assert( triangleB < navmesh->numTriangles );
	const float cost = ( float )vectorDistance( &navmesh->triangles[triangleA].center, &navmesh->triangles[triangleB].center );
	assert( cost > 0 );
	return cost;
}

static float heuristic( const QNavmesh *navmesh, int triangle, int endTriangle )
{
	assert( triangle >= 0 );
	assert( endTriangle >= 0 );
	assert( triangle < navmesh->numTriangles );
	assert( endTriangle < navmesh->numTriangles );
	const float cost = ( float )vectorDistance( &navmesh->triangles[triangle].center, &navmesh->triangles[endTriangle].center );
	return cost;
}

static int isTriangle( const QPathfinderNode *node, int *triangle )
{
	return node->triangle == *triangle;
}

static int hasBetterRank( const QPathfinderNode *nodeA, const QPathfinderNode *nodeB )
{
	return nodeA->cost + nodeA->heuristic <= nodeB->cost + nodeB->heuristic;
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

	QLinkedList openList, closedList;
	linkedListInit( &openList, sizeof( QPathfinderNode ), NULL );
	linkedListInit( &closedList, sizeof( QPathfinderNode ), NULL );

	QPathfinderNode startNode;
	startNode.cost = 0;
	startNode.previousTriangle = -1;
	startNode.triangle = startTriangle;
	startNode.heuristic = heuristic( navmesh, startNode.triangle, endTriangle );
	linkedListPrepend( &openList, &startNode );

	QPathfinderNode arrivalNode;
	while ( 1 )
	{
		QPathfinderNode current;
		assert( !linkedListIsEmpty( &openList ) ); // TODO Handle case where no path exists
		linkedListGetHead( &openList, &current );
		linkedListRemoveHead( &openList );
		linkedListPrepend( &closedList, &current );

		if ( current.triangle == endTriangle )
		{
			arrivalNode = current;
			break;
		}

		for ( int neighborIndex = 0; neighborIndex < 3; neighborIndex++ )
		{
			const int neighborTriangle = navmesh->triangles[current.triangle].neighbours[neighborIndex];
			if ( neighborTriangle < 0 )
			{
				continue;
			}
			assert( neighborTriangle < navmesh->numTriangles );

			const float newCost = current.cost + movementCost( navmesh, current.triangle, neighborTriangle );
			
			QPathfinderNode occurenceInOpenList;
			int inOpenList = linkedListFind( &openList, isTriangle, &neighborTriangle, &occurenceInOpenList );
			if ( inOpenList )
			{
				if ( newCost < occurenceInOpenList.cost )
				{
					linkedListRemove( &openList, isTriangle, &current.triangle );
					inOpenList = 0;
				}
			}
			const int inClosedList = linkedListFind( &closedList, isTriangle, &neighborTriangle, NULL );
			if ( !inOpenList && !inClosedList )
			{
				QPathfinderNode newNode;
				newNode.cost = newCost;
				newNode.triangle = neighborTriangle;
				newNode.heuristic = heuristic( navmesh, newNode.triangle, endTriangle );
				newNode.previousTriangle = current.triangle;
				linkedListInsertBefore( &openList, &newNode, hasBetterRank );
			}
		}

	}

	{
		int numPathVertices = 0;
		int currentTriangle = endTriangle;
		while ( currentTriangle != -1 )
		{
			assert( currentTriangle >= 0 );
			QPathfinderNode node;
			verify( linkedListFind( &closedList, isTriangle, &currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			numPathVertices++;
		}

		outPath->numVertices = numPathVertices;
		outPath->vertices = malloc( outPath->numVertices * sizeof( QVector ) );
	}
	
	{
		int nextPathVertexIndex = 0;
		int currentTriangle = endTriangle;
		while ( currentTriangle != -1 )
		{
			assert( currentTriangle >= 0 );
			assert( nextPathVertexIndex < outPath->numVertices );
			outPath->vertices[outPath->numVertices - 1 - nextPathVertexIndex] = navmesh->triangles[currentTriangle].center;

			QPathfinderNode node;
			verify( linkedListFind( &closedList, isTriangle, &currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			nextPathVertexIndex++;
		}
	}

	linkedListFree( &openList );
	linkedListFree( &closedList );

}