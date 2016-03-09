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

REAL vectorCrossProduct( const QVector *a, const QVector *b )
{
	return a->x * b->y - a->y * b->x;
}

int areVectorsColinear( const QVector *a, const QVector *b )
{
	return vectorCrossProduct( a, b ) == 0;
}

int isPointRightOfVector( const QVector *point, const QVector *vector )
{
	return vectorCrossProduct( vector, point ) > 0;
}

void flipEdge( QEdge *edge )
{
	QVector tmp;
	tmp = edge->start;
	edge->start = edge->end;
	edge->end = tmp;
}

void edgeMiddle( const QEdge *edge, QVector *result )
{
	result->x = ( edge->start.x + edge->end.x ) / 2;
	result->y = ( edge->start.y + edge->end.y ) / 2;
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

void getPushedVector( const QEdge *inEdgeA, const QEdge *inEdgeB, const QVector *outsidePointA, const QVector *outsidePointB, REAL padding, QVector *out )
{
	assert( vectorEquals( &inEdgeA->start, &inEdgeB->start ) );
	
	QVector vectorA;
	QVector vectorB;
	edgeToVector( inEdgeA, &vectorA );
	edgeToVector( inEdgeB, &vectorB );
	vectorNormalize( &vectorA );
	vectorNormalize( &vectorB );
	vectorScale( &vectorA, padding );
	vectorScale( &vectorB, padding );

	QVector outsideVectorA;
	QVector outsideVectorB;
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

		QEdge edgeA = *inEdgeA;
		QEdge edgeB = *inEdgeB;
		QVector edgeNormal;

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
