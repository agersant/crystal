#include <assert.h>
#include <math.h>
#include "vector_math.h"

int vectorEquals( const Vector *a, const Vector *b )
{
	return a->x == b->x && a->y == b->y;
}

REAL vectorLength( const Vector *vector )
{
	return sqrt( ( vector->x *vector->x ) + ( vector->y * vector->y ) );
}

void vectorAdd( const Vector *a, const Vector *b, Vector *result )
{
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void vectorSubtract( const Vector *a, const Vector *b, Vector *result )
{
	result->x = a->x - b->x;
	result->y = a->y - b->y;
}

void vectorNormalize( Vector *vector )
{
	REAL length = vectorLength( vector );
	assert( length > 0 );
	vector->x /= length;
	vector->y /= length;
}

void vectorScale( Vector *vector, REAL scale )
{
	vector->x *= scale;
	vector->y *= scale;
}

REAL vectorCrossProduct( const Vector *a, const Vector *b )
{
	return a->x * b->y - a->y * b->x;
}

int areVectorsColinear( const Vector *a, const Vector *b )
{
	return vectorCrossProduct( a, b ) == 0;
}

int isPointRightOfVector( const Vector *point, const Vector *vector )
{
	return vectorCrossProduct( vector, point ) > 0;
}

void flipEdge( Edge *edge )
{
	Vector tmp;
	tmp = edge->start;
	edge->start = edge->end;
	edge->end = tmp;
}

void edgeMiddle( const Edge *edge, Vector *result )
{
	result->x = ( edge->start.x + edge->end.x ) / 2;
	result->y = ( edge->start.y + edge->end.y ) / 2;
}

void edgeOffset( const Edge *edge, const Vector *offset, Edge *result )
{
	vectorAdd( &edge->start, offset, &result->start );
	vectorAdd( &edge->end, offset, &result->end );
}

void edgeToVector( const Edge *edge, Vector *vector )
{
	vector->x = edge->end.x - edge->start.x;
	vector->y = edge->end.y - edge->start.y;
}

void getPushedVector( const Edge *inEdgeA, const Edge *inEdgeB, const Vector *outsidePointA, const Vector *outsidePointB, REAL padding, Vector *out )
{
	assert( vectorEquals( &inEdgeA->start, &inEdgeB->start ) );
	
	Vector vectorA;
	Vector vectorB;
	edgeToVector( inEdgeA, &vectorA );
	edgeToVector( inEdgeB, &vectorB );
	vectorNormalize( &vectorA );
	vectorNormalize( &vectorB );
	vectorScale( &vectorA, padding );
	vectorScale( &vectorB, padding );

	Vector outsideVectorA;
	Vector outsideVectorB;
	vectorSubtract( outsidePointA, &inEdgeA->start, &outsideVectorA );
	vectorSubtract( outsidePointB, &inEdgeB->start, &outsideVectorB );

	assert( !areVectorsColinear( &vectorA, &outsideVectorA ) );
	assert( !areVectorsColinear( &vectorB, &outsideVectorB ) );

	out->x = 0;
	out->y = 0;

	const int isOutsidePointRightOfA = isPointRightOfVector( &outsideVectorA, &vectorA );
	const int isOutsidePointRightOfB = isPointRightOfVector( &outsideVectorB, &vectorB );

	if ( areVectorsColinear( &vectorA, &vectorB ) )
	{
		if ( isOutsidePointRightOfA )
		{
			out->x += -vectorA.y;
			out->y += vectorA.x;
		}
		else
		{
			out->x -= -vectorA.y;
			out->y -= vectorA.x;
		}
		vectorAdd( &inEdgeA->start, out, out );
	}
	else
	{

		Edge edgeA = *inEdgeA;
		Edge edgeB = *inEdgeB;
		Vector edgeNormal;

		if ( isOutsidePointRightOfA )
		{
			edgeNormal.x = -vectorA.y;
			edgeNormal.y = vectorA.x;
		}
		else
		{
			edgeNormal.x = vectorA.y;
			edgeNormal.y = -vectorA.x;
		}
		vectorNormalize( &edgeNormal );
		vectorScale( &edgeNormal, padding );
		edgeOffset( &edgeA, &edgeNormal, &edgeA );

		if ( isOutsidePointRightOfB )
		{
			edgeNormal.x = -vectorB.y;
			edgeNormal.y = vectorB.x;
		}
		else
		{
			edgeNormal.x = vectorB.y;
			edgeNormal.y = -vectorB.x;
		}
		vectorNormalize( &edgeNormal );
		vectorScale( &edgeNormal, padding );
		edgeOffset( &edgeB, &edgeNormal, &edgeB );

		const int intersects = lineIntersection( &edgeA, &edgeB, out );
		assert( intersects );
	}
}

int lineIntersection( const Edge *edgeA, const Edge *edgeB, Vector *outResult )
{
	const REAL x1 = edgeA->start.x;
	const REAL y1 = edgeA->start.y;
	const REAL x2 = edgeA->end.x;
	const REAL y2 = edgeA->end.y;
	const REAL x3 = edgeB->start.x;
	const REAL y3 = edgeB->start.y;
	const REAL x4 = edgeB->end.x;
	const REAL y4 = edgeB->end.y;
	const REAL det = ( x1 - x2 ) * ( y3 - y4 ) - ( y1 - y2 ) * ( x3 - x4 );
	if ( det == 0 )
	{
		return 0;
	}
	outResult->x = ( ( x1 * y2 - y1 * x2 ) * ( x3 - x4 ) - ( x1 - x2 ) * ( x3 * y4 - y3 * x4 ) ) / det;
	outResult->y = ( ( x1 * y2 - y1 * x2 ) * ( y3 - y4 ) - ( y1 - y2 ) * ( x3 * y4 - y3 * x4 ) ) / det;
	return 1;
}
