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

void vectorNormalize( Vector *vector )
{
	REAL length = vectorLength( vector );
	assert( length > 0 );
	vector->x /= length;
	vector->y /= length;
}

void flipEdge( Edge *edge )
{
	Vector tmp;
	tmp = edge->start;
	edge->start = edge->end;
	edge->end = tmp;
}

void edgeToVector( const Edge *edge, Vector *vector )
{
	vector->x = edge->end.x - edge->start.x;
	vector->y = edge->end.y - edge->start.y;
}

void getPushedVector( const Edge *edgeA, const Edge *edgeB, REAL padding, Vector *out )
{
	assert( vectorEquals( &edgeA->start, &edgeB->start ) );
	Vector vectorA;
	Vector vectorB;
	edgeToVector( edgeA, &vectorA );
	edgeToVector( edgeB, &vectorB );
	vectorNormalize( &vectorA );
	vectorNormalize( &vectorB );
	out->x = vectorA.x + vectorB.x;
	out->y = vectorA.y + vectorB.y;
	if ( vectorLength( out ) == 0 ) // TODO remove this and deal with colinear edges
	{
		*out = edgeA->start;
	}
	vectorNormalize( out );
	out->x *= padding;
	out->y *= padding;
	vectorAdd( &edgeA->start, out, out );
}
