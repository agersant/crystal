#include <assert.h>
#include <stdio.h>
#include "linked_list.h"
#include "navmesh_query.h"

typedef struct QAStarNode
{
	float cost;
	float heuristic;
	const QTriangle *triangle;
	const QTriangle *previousTriangle;
} QAStarNode;

typedef struct QAStarOutput
{
	const QTriangle **triangles;
	int numTriangles;
} QAStarOutput;

static int isPointInsideNavmeshTriangle( const QNavmesh *navmesh, const QVector *point, const QTriangle *triangle )
{
	const QVector *vertexA = &navmesh->vertices[triangle->vertices[0]];
	const QVector *vertexB = &navmesh->vertices[triangle->vertices[1]];
	const QVector *vertexC = &navmesh->vertices[triangle->vertices[2]];
	return doesTriangleContainPoint( vertexA, vertexB, vertexC, point );
}

static const QTriangle *findTriangleContainingPoint( const QNavmesh *navmesh, const QVector *point )
{
	assert( navmesh->numTriangles >= 0 );
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		const QTriangle *triangle = &navmesh->triangles[triangleIndex];
		if ( isPointInsideNavmeshTriangle( navmesh, point, triangle ) )
		{
			return triangle;
		}
	}
	return NULL;
}

static float movementCost( const QTriangle *triangleA, const QTriangle *triangleB )
{
	assert( triangleA != NULL );
	assert( triangleB != NULL );
	assert( triangleA != triangleB );
	const float cost = ( float )vectorDistance( &triangleA->center, &triangleB->center );
	assert( cost > 0 );
	return cost;
}

static float heuristic( const QTriangle *triangle, const QVector *destination )
{
	assert( triangle != NULL );
	assert( destination != NULL );
	const float cost = ( float )vectorDistance( &triangle->center, destination );
	return cost;
}

static int hasBetterRank( const QAStarNode *nodeA, const QAStarNode *nodeB )
{
	return nodeA->cost + nodeA->heuristic <= nodeB->cost + nodeB->heuristic;
}

static int isTriangle( const QAStarNode *node, const QTriangle *triangle )
{
	return node->triangle == triangle;
}

static void getPortal( const QNavmesh *navmesh, const QTriangle *triangleA, const QTriangle *triangleB, QEdge *outEdge )
{
	for ( int i = 0; i < 3; i++ )
	{
		const int vertexIndex = triangleA->vertices[i];
		const int nextVertexIndex = triangleA->vertices[( i + 1 ) % 3];
		const int isShared = triangleB->vertices[0] == vertexIndex || triangleB->vertices[1] == vertexIndex || triangleB->vertices[2] == vertexIndex;
		const int isNextShared = triangleB->vertices[0] == nextVertexIndex || triangleB->vertices[1] == nextVertexIndex || triangleB->vertices[2] == nextVertexIndex;
		if ( isShared && isNextShared )
		{
			outEdge->start = navmesh->vertices[vertexIndex];
			outEdge->end = navmesh->vertices[nextVertexIndex];
			return;
		}
	}
	assert( 0 ); // Triangles don't have a shared edge
}

static REAL triangleArea2( const QVector *vertexA, const QVector *vertexB, const QVector *vertexC )
{
	QVector ab, ac;
	vectorSubtract( vertexB, vertexA, &ab );
	vectorSubtract( vertexC, vertexA, &ac );
	return vectorCrossProduct( &ac, &ab );
}

// Based on: http://digestingduck.blogspot.com/2010/03/simple-stupid-funnel-algorithm.html
static void funnelPath( const QNavmesh *navmesh, const QVector *start, const QVector *end, const QAStarOutput *aStarOutput, QPath *outPath )
{
	const int numTriangles = aStarOutput->numTriangles;
	const QTriangle **triangles = aStarOutput->triangles;

	if ( numTriangles < 1 )
	{
		outPath->numVertices = 0;
		outPath->vertices = NULL;
		return;
	}

	if ( numTriangles == 1 )
	{
		outPath->numVertices = 2;
		outPath->vertices = malloc( 2 * sizeof( QVector ) );
		outPath->vertices[0] = *start;
		outPath->vertices[1] = *end;
		return;
	}

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

static void aStar( const QNavmesh *navmesh, const QVector *start, const QVector *end, QAStarOutput *output )
{
	const QTriangle *const startTriangle = findTriangleContainingPoint( navmesh, start );
	const QTriangle *const endTriangle = findTriangleContainingPoint( navmesh, end );

	if ( startTriangle == NULL || endTriangle == NULL )
	{
		// TODO Return a decent path if start/end isn't on navmesh
		output->numTriangles = 0;
		output->triangles = NULL;
		return;
	}

	QLinkedList openList, closedList;
	linkedListInit( &openList, sizeof( QAStarNode ), NULL );
	linkedListInit( &closedList, sizeof( QAStarNode ), NULL );

	QAStarNode startNode;
	startNode.cost = 0;
	startNode.previousTriangle = NULL;
	startNode.triangle = startTriangle;
	startNode.heuristic = heuristic( startNode.triangle, end );
	linkedListPrepend( &openList, &startNode );

	QAStarNode arrivalNode;
	while ( 1 )
	{
		QAStarNode current;
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
			const int neighborTriangleIndex = current.triangle->neighbours[neighborIndex];
			assert( neighborTriangleIndex < navmesh->numTriangles );
			const QTriangle *neighborTriangle = &navmesh->triangles[neighborTriangleIndex];
			if ( neighborTriangle < 0 )
			{
				continue;
			}

			const float newCost = current.cost + movementCost( current.triangle, neighborTriangle );

			QAStarNode occurenceInOpenList;
			int inOpenList = linkedListFind( &openList, isTriangle, neighborTriangle, &occurenceInOpenList );
			if ( inOpenList )
			{
				if ( newCost < occurenceInOpenList.cost )
				{
					linkedListRemove( &openList, isTriangle, &current.triangle );
					inOpenList = 0;
				}
			}
			const int inClosedList = linkedListFind( &closedList, isTriangle, neighborTriangle, NULL );
			if ( !inOpenList && !inClosedList )
			{
				QAStarNode newNode;
				newNode.cost = newCost;
				newNode.triangle = neighborTriangle;
				newNode.heuristic = heuristic( newNode.triangle, end );
				newNode.previousTriangle = current.triangle;
				linkedListInsertBefore( &openList, &newNode, hasBetterRank );
			}
		}
	}

	output->numTriangles = 0;
	{
		const QTriangle *currentTriangle = endTriangle;
		while ( currentTriangle != NULL )
		{
			assert( currentTriangle >= 0 );
			QAStarNode node;
			verify( linkedListFind( &closedList, isTriangle, currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			output->numTriangles++;
		}
	}

	output->triangles = malloc( sizeof( QTriangle * ) * output->numTriangles );
	{
		int nextPathTriangleIndex = output->numTriangles - 1;
		const QTriangle *currentTriangle = endTriangle;
		while ( currentTriangle != NULL )
		{
			assert( currentTriangle >= 0 );
			assert( nextPathTriangleIndex >= 0 );
			assert( nextPathTriangleIndex < output->numTriangles );
			output->triangles[nextPathTriangleIndex] = currentTriangle;

			QAStarNode node;
			verify( linkedListFind( &closedList, isTriangle, currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			nextPathTriangleIndex--;
		}
	}

	linkedListFree( &openList );
	linkedListFree( &closedList );

	assert( output->triangles[0] == startTriangle );
	assert( output->triangles[output->numTriangles - 1] == endTriangle );
}

static void freeAStarOutput( QAStarOutput *aStarOutput )
{
	free( aStarOutput->triangles );
	aStarOutput->triangles = NULL;
	aStarOutput->numTriangles = 0;
}

void pathfinder( const QNavmesh *navmesh, const QVector *start, const QVector *end, QPath *outPath )
{
	assert( outPath->numVertices == 0 );
	
	QAStarOutput aStarOutput;
	aStar( navmesh, start, end, &aStarOutput );
	
	funnelPath( navmesh, start, end, &aStarOutput, outPath );
	
	freeAStarOutput( &aStarOutput );
}