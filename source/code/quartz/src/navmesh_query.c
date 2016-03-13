#include <assert.h>
#include <stdio.h>
#include "linked_list.h"
#include "navmesh_query.h"

typedef struct QPathfinderNode
{
	float cost;
	float heuristic;
	int triangle; // TODO use QTriangle *
	int previousTriangle; // TODO use QTriangle *
} QPathfinderNode;

static int isPointInsideNavmeshTriangle( const QNavmesh *navmesh, const QVector *point, int triangle )
{
	const QVector *vertexA = &navmesh->vertices[navmesh->triangles[triangle].vertices[0]];
	const QVector *vertexB = &navmesh->vertices[navmesh->triangles[triangle].vertices[1]];
	const QVector *vertexC = &navmesh->vertices[navmesh->triangles[triangle].vertices[2]];
	return doesTriangleContainPoint( vertexA, vertexB, vertexC, point );
}

static int findTriangleContainingPoint( const QNavmesh *navmesh, const QVector *point )
{
	assert( navmesh->numTriangles >= 0 );
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		if ( isPointInsideNavmeshTriangle( navmesh, point, triangleIndex ) )
		{
			return triangleIndex;
		}
	}
	return -1;
}

static int areTrianglesNeighbors( const QNavmesh *navmesh, int triangleA, int triangleB )
{
	return 1; // TODO
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

static void getPortal( const QNavmesh *navmesh, int triangleA, int triangleB, QEdge *outEdge )
{
	assert( areTrianglesNeighbors( navmesh, triangleA, triangleB ) );
	const QTriangle *a = &navmesh->triangles[triangleA];
	const QTriangle *b = &navmesh->triangles[triangleB];
	for ( int i = 0; i < 3; i++ )
	{
		const int vertexIndex = a->vertices[i];
		const int nextVertexIndex = a->vertices[( i + 1 ) % 3];
		const int isShared = b->vertices[0] == vertexIndex || b->vertices[1] == vertexIndex || b->vertices[2] == vertexIndex;
		const int isNextShared = b->vertices[0] == nextVertexIndex || b->vertices[1] == nextVertexIndex || b->vertices[2] == nextVertexIndex;
		if ( isShared && isNextShared )
		{
			outEdge->start = navmesh->vertices[vertexIndex];
			outEdge->end = navmesh->vertices[nextVertexIndex];
			return;
		}
	}
	assert( 0 );
}

static REAL triangleArea2( const QVector *vertexA, const QVector *vertexB, const QVector *vertexC )
{
	QVector ab, ac;
	vectorSubtract( vertexB, vertexA, &ab );
	vectorSubtract( vertexC, vertexA, &ac );
	return vectorCrossProduct( &ac, &ab );
}

// Based on: http://digestingduck.blogspot.com/2010/03/simple-stupid-funnel-algorithm.html
static void funnelPath( const QNavmesh *navmesh, const QVector *start, const QVector *end, int numTriangles, int *triangles, QPath *outPath )
{
	assert( outPath->vertices == NULL );
	assert( numTriangles > 1 );
	assert( isPointInsideNavmeshTriangle( navmesh, start, triangles[0] ) );
	assert( isPointInsideNavmeshTriangle( navmesh, end, triangles[numTriangles - 1] ) );

	const int numPortals = numTriangles;
	QEdge *portals = malloc( numPortals * sizeof( QEdge ) );

	const int maxVertices = numTriangles + 1;
	outPath->vertices = malloc( sizeof( QVector ) * maxVertices );
	outPath->vertices[0] = *start;
	outPath->numVertices = 1;

	for ( int triangleIndex = 0; triangleIndex < numTriangles - 1; triangleIndex++ )
	{
		assert( triangleIndex < numTriangles );
		assert( triangleIndex < numPortals - 1 );
		assert( triangleIndex + 1 < numTriangles );
		getPortal( navmesh, triangles[triangleIndex], triangles[triangleIndex + 1], &portals[triangleIndex] );
	}
	portals[numPortals - 1].start = *end;
	portals[numPortals - 1].end = *end;

	QVector portalApex, portalLeft, portalRight;
	portalApex = *start;
	portalLeft = *start;
	portalRight = *start;

	int apexIndex, leftIndex, rightIndex;
	apexIndex = 0;
	leftIndex = 0;
	rightIndex = 0;

	for ( int portalIndex = 0; portalIndex < numPortals; portalIndex++ )
	{
		const QVector *right = &portals[portalIndex].start;
		const QVector *left = &portals[portalIndex].end;

		if ( triangleArea2( &portalApex, &portalRight, right ) <= 0 )
		{
			if ( vectorEquals( &portalApex, &portalRight ) || triangleArea2( &portalApex, &portalLeft, right ) > 0 )
			{
				// Tighten
				portalRight = *right;
				rightIndex = portalIndex;
			}
			else
			{
				// Right over left, insert left to path and restart scan from portal left point
				assert( outPath->numVertices < maxVertices );
				assert( !vectorEquals( &portalLeft, &outPath->vertices[outPath->numVertices - 1] ) );
				outPath->vertices[outPath->numVertices] = portalLeft;
				outPath->numVertices++;
				// Make current left the new apex
				portalApex = portalLeft;
				apexIndex = leftIndex;
				// Reset portal
				portalLeft = portalApex;
				portalRight = portalApex;
				leftIndex = apexIndex;
				rightIndex = apexIndex;
				// Restart scan
				portalIndex = apexIndex;
				continue;
			}
		}

		if ( triangleArea2( &portalApex, &portalLeft, left ) >= 0 )
		{
			if ( vectorEquals( &portalApex, &portalLeft ) || triangleArea2( &portalApex, &portalRight, left ) < 0 )
			{
				// Tighten
				portalLeft = *left;
				leftIndex = portalIndex;
			}
			else
			{
				// Left over right, insert right to path and restart scan from portal right point
				assert( outPath->numVertices < maxVertices );
				assert( !vectorEquals( &portalRight, &outPath->vertices[outPath->numVertices - 1] ) );
				outPath->vertices[outPath->numVertices] = portalRight;
				outPath->numVertices++;
				// Make current right the new apex
				portalApex = portalRight;
				apexIndex = rightIndex;
				// Reset portal
				portalLeft = portalApex;
				portalRight = portalApex;
				leftIndex = apexIndex;
				rightIndex = apexIndex;
				// Restart scan
				portalIndex = apexIndex;
				continue;
			}
		}
	}

	assert( vectorEquals( &outPath->vertices[0], start ) );
	assert( vectorEquals( &outPath->vertices[outPath->numVertices - 1], end ) );

	free( portals );
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

	if ( startTriangle == endTriangle )
	{
		outPath->numVertices = 2;
		outPath->vertices = malloc( 2 * sizeof( QVector ) );
		outPath->vertices[0] = *start;
		outPath->vertices[1] = *end;
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

	int numPathTriangles = 0;
	{
		int currentTriangle = endTriangle;
		while ( currentTriangle != -1 )
		{
			assert( currentTriangle >= 0 );
			QPathfinderNode node;
			verify( linkedListFind( &closedList, isTriangle, &currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			numPathTriangles++;
		}
	}
	assert( numPathTriangles > 1 );
	
	int *pathTriangles = malloc( sizeof( int ) * numPathTriangles );
	{
		int nextPathTriangleIndex = numPathTriangles - 1;
		int currentTriangle = endTriangle;
		while ( currentTriangle != -1 )
		{
			assert( currentTriangle >= 0 );
			assert( nextPathTriangleIndex >= 0 );
			assert( nextPathTriangleIndex < numPathTriangles );
			pathTriangles[nextPathTriangleIndex] = currentTriangle;

			QPathfinderNode node;
			verify( linkedListFind( &closedList, isTriangle, &currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			nextPathTriangleIndex--;
		}
	}
	
	funnelPath( navmesh, start, end, numPathTriangles, pathTriangles, outPath );
	
	free( pathTriangles );
	linkedListFree( &openList );
	linkedListFree( &closedList );
}