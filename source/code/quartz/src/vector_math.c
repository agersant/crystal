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

REAL vectorLength2( const QVector *vector )
{
	return ( vector->x * vector->x ) + ( vector->y * vector->y );
}

REAL vectorDistance2( const QVector *a, const QVector *b )
{
	QVector difference;
	vectorSubtract( a, b, &difference );
	return vectorLength2( &difference );
}

void vectorAdd( const QVector *a, const QVector *b, QVector *result )
{
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void vectorMadd( const QVector *a, REAL m, const QVector *b, QVector *result )
{
	result->x = a->x + m * b->x;
	result->y = a->y + m * b->y;
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

REAL vectorDotProduct( const QVector *a, const QVector *b )
{
	return a->x * b->x + a->y * b->y;
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

void projectPointOntoSegment( const QVector *point, const QEdge *line, QVector *outResult )
{
	assert( !vectorEquals( &line->start, &line->end ) );
	QVector AB, AP;
	vectorSubtract( &line->end, &line->start, &AB );
	vectorSubtract( point, &line->start, &AP );
	const REAL length2 = vectorDistance2( &line->start, &line->end );
	const REAL t = vectorDotProduct( &AB, &AP ) / length2;
	vectorMadd( &line->start, t, &AB, outResult );
}

int doesTriangleContainPoint( const QVector *a, const QVector *b, const QVector *c, const QVector *point )
{
	QVector ac, ab, ap;
	vectorSubtract( c, a, &ac );
	vectorSubtract( b, a, &ab );
	vectorSubtract( point, a, &ap );
	const REAL dotACAC = vectorDotProduct( &ac, &ac );
	const REAL dotACAB = vectorDotProduct( &ac, &ab );
	const REAL dotACAP = vectorDotProduct( &ac, &ap );
	const REAL dotABAB = vectorDotProduct( &ab, &ab );
	const REAL dotABAP = vectorDotProduct( &ab, &ap );

	const REAL denom = dotACAC * dotABAB - dotACAB * dotACAB;
	assert( denom != 0 );
	const REAL u = ( dotABAB * dotACAP - dotACAB * dotABAP ) / denom;
	const REAL v = ( dotACAC * dotABAP - dotACAB * dotACAP ) / denom;
	return u >= 0 && u >= 0 && u + v <= 1;
}
