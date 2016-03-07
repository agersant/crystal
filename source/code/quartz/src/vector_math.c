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

REAL vectorCrossProduct( Vector *a, Vector *b )
{
	return a->x * b->y - a->y * b->x;
}

void flipEdge( Edge *edge )
{
	Vector tmp;
	tmp = edge->start;
	edge->start = edge->end;
	edge->end = tmp;
}

void edgeMiddle( const Edge * edge, Vector * result )
{
	result->x = ( edge->start.x + edge->end.x ) / 2;
	result->y = ( edge->start.y + edge->end.y ) / 2;
}

void edgeToVector( const Edge *edge, Vector *vector )
{
	vector->x = edge->end.x - edge->start.x;
	vector->y = edge->end.y - edge->start.y;
}

void getPushedVector( const Edge *edgeA, const Edge *edgeB, const Vector *outsidePoint, REAL padding, Vector *out )
{
	assert( vectorEquals( &edgeA->start, &edgeB->start ) );
	Vector vectorA;
	Vector vectorB;
	edgeToVector( edgeA, &vectorA );
	edgeToVector( edgeB, &vectorB );
	vectorNormalize( &vectorA );
	vectorNormalize( &vectorB );
	vectorScale( &vectorA, padding );
	vectorScale( &vectorB, padding );

	Vector vectorOutside;
	vectorSubtract( outsidePoint, &edgeA->start, &vectorOutside );

	out->x = 0;
	out->y = 0;

	if ( vectorCrossProduct( &vectorA, &vectorB ) == 0 )
	{
		const int isOutsidePointLeftOfA = vectorCrossProduct( &vectorA, &vectorOutside ) < 0;
		if ( isOutsidePointLeftOfA )
		{
			out->x -= -vectorA.y;
			out->y -= vectorA.x;
		}
		else
		{
			out->x += -vectorA.y;
			out->y += vectorA.x;
		}
	}
	else
	{
		const int isOutsidePointWithinAB = ( vectorCrossProduct( &vectorA, &vectorOutside ) * vectorCrossProduct( &vectorB, &vectorOutside ) ) < 0;

		const int isOutsidePointLeftOfA = vectorCrossProduct( &vectorA, &vectorOutside ) < 0;
		if ( isOutsidePointLeftOfA && isOutsidePointWithinAB ) // TODO fix me
		{
			out->x -= -vectorA.y;
			out->y -= vectorA.x;
		}
		else
		{
			out->x += -vectorA.y;
			out->y += vectorA.x;
		}

		if ( vectorCrossProduct( &vectorA, &vectorB ) != 0 )
		{
			const int isOutsidePointLeftOfB = vectorCrossProduct( &vectorB, &vectorOutside ) < 0;
			if ( isOutsidePointLeftOfB && isOutsidePointWithinAB ) // TODO fix me
			{
				out->x -= -vectorB.y;
				out->y -= vectorB.x;
			}
			else
			{
				out->x += -vectorB.y;
				out->y += vectorB.x;
			}
		}
	}

	vectorAdd( &edgeA->start, out, out );
}
