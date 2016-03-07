#pragma once
#include "types.h"

typedef struct Vector
{
	REAL x;
	REAL y;
} Vector;

typedef struct Edge
{
	Vector start;
	Vector end;
} Edge;

int vectorEquals( const Vector *a, const Vector *b );
REAL vectorLength( const Vector *vector );
void vectorAdd( const Vector *a, const Vector *b, Vector *result );
void vectorNormalize( Vector *vector );
void flipEdge( Edge *edge );
void getPushedVector( const Edge *edgeA, const Edge *edgeB, REAL padding, Vector *out );
