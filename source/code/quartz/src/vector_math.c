#include <assert.h>
#include <math.h>
#include "vector_math.h"

int vectorEquals( const QVector *a, const QVector *b )
{
	return a->x == b->x && a->y == b->y;
}

REAL vectorLength( const QVector *vector )
{
	return sqrt( ( vector->x *vector->x ) + ( vector->y * vector->y ) );
}

void vectorAdd( const QVector *a, const QVector *b, QVector *result )
{
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void vectorSubtract( const QVector *a, const QVector *b, QVector *result )
{
	result->x = a->x - b->x;
	result->y = a->y - b->y;
}

void vectorNormalize( QVector *vector )
{
	REAL length = vectorLength( vector );
	assert( length > 0 );
	vector->x /= length;
	vector->y /= length;
}

void vectorScale( QVector *vector, REAL scale )
{
	vector->x *= scale;
	vector->y *= scale;
}

void vectorNormal( const QVector *vector, int left, QVector *outNormal )
{
	outNormal->x = -vector->y;
	outNormal->y = vector->x;
	if ( left )
	{
		vectorScale( outNormal, -1 );
	}
}

REAL vectorCrossProduct( const QVector *a, const QVector *b )
{
	return a->x * b->y - a->y * b->x;
}

int areVectorsColinear( const QVector *a, const QVector *b )
{
	return vectorCrossProduct( a, b ) == 0;
}

void edgeOffset( const QEdge *edge, const QVector *offset, QEdge *result )
{
	vectorAdd( &edge->start, offset, &result->start );
	vectorAdd( &edge->end, offset, &result->end );
}

void edgeToVector( const QEdge *edge, QVector *vector )
{
	vector->x = edge->end.x - edge->start.x;
	vector->y = edge->end.y - edge->start.y;
}

int lineIntersection( const QEdge *edgeA, const QEdge *edgeB, QVector *outResult )
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
