#include <assert.h>
#include <float.h>
#include <stdio.h>
#include <string.h>
#include "linked_list.h"
#include "navmesh_query.h"

typedef struct BAStarNode
{
	float cost;
	float heuristic;
	const BTriangle *triangle;
	const BTriangle *previousTriangle;
} BAStarNode;

typedef struct BAStarOutput
{
	const BTriangle **triangles;
	int numTriangles;
} BAStarOutput;

static int isPointInsideNavmeshTriangle( const BNavmesh *navmesh, const BVector *point, const BTriangle *triangle )
{
	const BVector *vertexA = &navmesh->vertices[triangle->vertices[0]];
	const BVector *vertexB = &navmesh->vertices[triangle->vertices[1]];
	const BVector *vertexC = &navmesh->vertices[triangle->vertices[2]];
	return doesTriangleContainPoint( vertexA, vertexB, vertexC, point );
}

static const BTriangle *findTriangleContainingPoint( const BNavmesh *navmesh, const BVector *point )
{
	assert( navmesh->numTriangles >= 0 );
	// TODO.optimization This could be more efficient if triangles were stored in
	// a more appropriate data structure (eg. quadtree).
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		const BTriangle *triangle = &navmesh->triangles[triangleIndex];
		if ( isPointInsideNavmeshTriangle( navmesh, point, triangle ) )
		{
			return triangle;
		}
	}
	return NULL;
}

static void projectPointOntoNavmeshTriangle( const BNavmesh *navmesh, const BVector *point, const BTriangle *triangle, BVector *outPoint )
{
	const BVector *vertexA = &navmesh->vertices[triangle->vertices[0]];
	const BVector *vertexB = &navmesh->vertices[triangle->vertices[1]];
	const BVector *vertexC = &navmesh->vertices[triangle->vertices[2]];
	projectPointOntoTriangle( vertexA, vertexB, vertexC, point, outPoint );
}

static void projectPointOntoNavmesh( const BNavmesh *navmesh, const BVector *point, const BTriangle **outTriangle, BVector *outPoint )
{
	assert( navmesh->numTriangles >= 0 );
	REAL bestDist2 = DBL_MAX;

	// TODO.optimization This could be more efficient if triangles were stored in
	// a more appropriate data structure (eg. quadtree).
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		const BTriangle *triangle = &navmesh->triangles[triangleIndex];

		BVector projectedPoint;
		projectPointOntoNavmeshTriangle( navmesh, point, triangle, &projectedPoint );

		const REAL distToNavmesh2 = vectorDistance2( point, &projectedPoint );
		if ( distToNavmesh2 < bestDist2 )
		{
			bestDist2 = distToNavmesh2;
			*outPoint = projectedPoint;
			*outTriangle = triangle;
		}
	}

	assert( bestDist2 != DBL_MAX );
}


static void projectPointOntoConnectedComponent( const BNavmesh *navmesh, const BVector *point, int connectedComponent, const BTriangle **outTriangle, BVector *outPoint )
{
	assert( navmesh->numTriangles >= 0 );
	REAL bestDist2 = DBL_MAX;

	// TODO.optimization This could be more efficient if triangles were stored in
	// a more appropriate data structure (eg. quadtree).
	for ( int triangleIndex = 0; triangleIndex < navmesh->numTriangles; triangleIndex++ )
	{
		const BTriangle *triangle = &navmesh->triangles[triangleIndex];
		if ( triangle->connectedComponent != connectedComponent )
		{
			continue;
		}

		BVector projectedPoint;
		projectPointOntoNavmeshTriangle( navmesh, point, triangle, &projectedPoint );

		const REAL distToNavmesh2 = vectorDistance2( point, &projectedPoint );
		if ( distToNavmesh2 < bestDist2 )
		{
			bestDist2 = distToNavmesh2;
			*outPoint = projectedPoint;
			*outTriangle = triangle;
		}
	}

	assert( bestDist2 != DBL_MAX );
}


static float movementCost( const BTriangle *triangleA, const BTriangle *triangleB )
{
	assert( triangleA != NULL );
	assert( triangleB != NULL );
	assert( triangleA != triangleB );
	const float cost = ( float )vectorDistance( &triangleA->center, &triangleB->center );
	assert( cost > 0 );
	return cost;
}

static float heuristic( const BTriangle *triangle, const BVector *destination )
{
	assert( triangle != NULL );
	assert( destination != NULL );
	const float cost = ( float )vectorDistance( &triangle->center, destination );
	return cost;
}

static int hasBetterRank( const BAStarNode *nodeA, const BAStarNode *nodeB )
{
	return nodeA->cost + nodeA->heuristic <= nodeB->cost + nodeB->heuristic;
}

static int isTriangle( const BAStarNode *node, const BTriangle *triangle )
{
	return node->triangle == triangle;
}

static void getPortal( const BNavmesh *navmesh, const BTriangle *triangleA, const BTriangle *triangleB, BEdge *outEdge )
{
	// TODO.optimization These results could be precomputed
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

static REAL triangleArea2( const BVector *vertexA, const BVector *vertexB, const BVector *vertexC )
{
	BVector ab, ac;
	vectorSubtract( vertexB, vertexA, &ab );
	vectorSubtract( vertexC, vertexA, &ac );
	return vectorCrossProduct( &ac, &ab );
}

// Based on: http://digestingduck.blogspot.com/2010/03/simple-stupid-funnel-algorithm.html
static void funnelPath( const BNavmesh *navmesh, const BVector *start, const BVector *end, const BAStarOutput *aStarOutput, BPath *outPath )
{
	const int numTriangles = aStarOutput->numTriangles;
	const BTriangle **triangles = aStarOutput->triangles;

	if ( numTriangles < 1 )
	{
		outPath->numVertices = 0;
		outPath->vertices = NULL;
		return;
	}

	if ( numTriangles == 1 )
	{
		outPath->numVertices = 2;
		outPath->vertices = malloc( 2 * sizeof( BVector ) );
		outPath->vertices[0] = *start;
		outPath->vertices[1] = *end;
		return;
	}

	assert( isPointInsideNavmeshTriangle( navmesh, start, triangles[0] ) );
	assert( isPointInsideNavmeshTriangle( navmesh, end, triangles[numTriangles - 1] ) );

	const int numPortals = numTriangles;
	BEdge *portals = malloc( numPortals * sizeof( BEdge ) );

	const int maxVertices = numTriangles + 1;
	outPath->vertices = malloc( sizeof( BVector ) * maxVertices );
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

	BVector portalApex, portalLeft, portalRight;
	portalApex = *start;
	portalLeft = *start;
	portalRight = *start;

	int apexIndex, leftIndex, rightIndex;
	apexIndex = 0;
	leftIndex = 0;
	rightIndex = 0;

	for ( int portalIndex = 0; portalIndex < numPortals; portalIndex++ )
	{
		const BVector *right = &portals[portalIndex].start;
		const BVector *left = &portals[portalIndex].end;

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
				if ( !vectorEquals( &portalLeft, &outPath->vertices[outPath->numVertices - 1] ) )
				{
					outPath->vertices[outPath->numVertices] = portalLeft;
					outPath->numVertices++;
				}
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
				if ( !vectorEquals( &portalRight, &outPath->vertices[outPath->numVertices - 1] ) )
				{
					outPath->vertices[outPath->numVertices] = portalRight;
					outPath->numVertices++;
				}
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
	if ( !vectorEquals( &outPath->vertices[outPath->numVertices - 1], end ) )
	{
		assert( outPath->numVertices < maxVertices );
		outPath->vertices[outPath->numVertices - 1] = *end;
		outPath->numVertices++;
	}

	free( portals );
}

static void aStar( const BNavmesh *navmesh, const BTriangle *startTriangle, const BTriangle *endTriangle, const BVector *destination, BAStarOutput *output )
{
	assert( navmesh != NULL );
	assert( startTriangle != NULL );
	assert( endTriangle != NULL );
	assert( destination != NULL );
	assert( output != NULL );
	assert( isPointInsideNavmeshTriangle( navmesh, destination, endTriangle) );
	assert( startTriangle->connectedComponent == endTriangle->connectedComponent );

	BLinkedList openList, closedList;
	linkedListInit( &openList, sizeof( BAStarNode ), NULL );
	linkedListInit( &closedList, sizeof( BAStarNode ), NULL );

	BAStarNode startNode;
	startNode.cost = 0;
	startNode.previousTriangle = NULL;
	startNode.triangle = startTriangle;
	startNode.heuristic = heuristic( startNode.triangle, destination );
	linkedListPrepend( &openList, &startNode );

	BAStarNode arrivalNode;
	while ( 1 )
	{
		BAStarNode current;
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
			if ( neighborTriangleIndex < 0 )
			{
				continue;
			}
			const BTriangle *neighborTriangle = &navmesh->triangles[neighborTriangleIndex];

			const float newCost = current.cost + movementCost( current.triangle, neighborTriangle );

			BAStarNode occurenceInOpenList;
			int inOpenList = linkedListFind( &openList, isTriangle, ( void * ) neighborTriangle, &occurenceInOpenList );
			if ( inOpenList )
			{
				if ( newCost < occurenceInOpenList.cost )
				{
					linkedListRemove( &openList, isTriangle, ( void * ) &current.triangle );
					inOpenList = 0;
				}
			}
			const int inClosedList = linkedListFind( &closedList, isTriangle, ( void * ) neighborTriangle, NULL );
			if ( !inOpenList && !inClosedList )
			{
				BAStarNode newNode;
				newNode.cost = newCost;
				newNode.triangle = neighborTriangle;
				newNode.heuristic = heuristic( newNode.triangle, destination );
				newNode.previousTriangle = current.triangle;
				linkedListInsertBefore( &openList, &newNode, hasBetterRank );
			}
		}
	}

	output->numTriangles = 0;
	{
		const BTriangle *currentTriangle = endTriangle;
		while ( currentTriangle != NULL )
		{
			assert( currentTriangle >= 0 );
			BAStarNode node;
			verify( linkedListFind( &closedList, isTriangle, ( void * ) currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			output->numTriangles++;
		}
	}

	output->triangles = malloc( sizeof( BTriangle * ) * output->numTriangles );
	{
		int nextPathTriangleIndex = output->numTriangles - 1;
		const BTriangle *currentTriangle = endTriangle;
		while ( currentTriangle != NULL )
		{
			assert( currentTriangle >= 0 );
			assert( nextPathTriangleIndex >= 0 );
			assert( nextPathTriangleIndex < output->numTriangles );
			output->triangles[nextPathTriangleIndex] = currentTriangle;

			BAStarNode node;
			verify( linkedListFind( &closedList, isTriangle, ( void * ) currentTriangle, &node ) );
			currentTriangle = node.previousTriangle;
			nextPathTriangleIndex--;
		}
	}

	linkedListFree( &openList );
	linkedListFree( &closedList );

	assert( output->triangles[0] == startTriangle );
	assert( output->triangles[output->numTriangles - 1] == endTriangle );
}

static void freeAStarOutput( BAStarOutput *aStarOutput )
{
	free( ( BTriangle ** ) aStarOutput->triangles );
	aStarOutput->triangles = NULL;
	aStarOutput->numTriangles = 0;
}

void pathfinder( const BNavmesh *navmesh, const BVector *start, const BVector *end, BPath *outPath )
{
	assert( outPath->numVertices == 0 );
	
	const BTriangle *const startTriangle = findTriangleContainingPoint( navmesh, start );
	const BTriangle *const endTriangle = findTriangleContainingPoint( navmesh, end );
	const BTriangle *adjustedStartTriangle, *adjustedEndTriangle;
	BVector adjustedStart, adjustedEnd;

	if ( startTriangle == NULL )
	{
		projectPointOntoNavmesh( navmesh, start, &adjustedStartTriangle, &adjustedStart );
	}
	else
	{
		adjustedStart = *start;
		adjustedStartTriangle = startTriangle;
	}
	assert( adjustedStartTriangle );

	const int isDestinationReachable = endTriangle != NULL && endTriangle->connectedComponent == adjustedStartTriangle->connectedComponent;
	if ( !isDestinationReachable )
	{
		projectPointOntoConnectedComponent( navmesh, end, adjustedStartTriangle->connectedComponent, &adjustedEndTriangle, &adjustedEnd );
	}
	else
	{
		adjustedEnd = *end;
		adjustedEndTriangle = endTriangle;
	}
	assert( adjustedEndTriangle );

	assert( isPointInsideNavmeshTriangle( navmesh, &adjustedStart, adjustedStartTriangle ) );
	assert( isPointInsideNavmeshTriangle( navmesh, &adjustedEnd, adjustedEndTriangle ) );

	BAStarOutput aStarOutput;
	aStar( navmesh, adjustedStartTriangle, adjustedEndTriangle, &adjustedEnd, &aStarOutput );
	
	funnelPath( navmesh, &adjustedStart, &adjustedEnd, &aStarOutput, outPath );
	
	freeAStarOutput( &aStarOutput );
	
	assert( outPath->numVertices > 0 );
	assert( outPath->vertices != NULL );

	if ( !vectorEquals( start, &adjustedStart ) )
	{
		BVector *newVertices = malloc( ( 1 + outPath->numVertices ) * sizeof( BVector ) );
		newVertices[0] = *start;
		memcpy( &newVertices[1], outPath->vertices, ( outPath->numVertices ) * sizeof( BVector ) );
		free( outPath->vertices );
		outPath->vertices = newVertices;
		outPath->numVertices++;
	}

	if ( isDestinationReachable && !vectorEquals( end, &adjustedEnd ) )
	{
		BVector *newVertices = malloc( ( 1 + outPath->numVertices ) * sizeof( BVector ) );
		newVertices[outPath->numVertices] = *end;
		memcpy( newVertices, outPath->vertices, ( outPath->numVertices ) * sizeof( BVector ) );
		free( outPath->vertices );
		outPath->vertices = newVertices;
		outPath->numVertices++;
	}
	
}
