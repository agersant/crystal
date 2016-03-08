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
void vectorSubtract( const Vector *a, const Vector *b, Vector *result );
void vectorNormalize( Vector *vector );
void vectorScale( Vector *vector, REAL scale );
REAL vectorCrossProduct( const Vector *a, const Vector *b );
int areVectorsColinear( const Vector *a, const Vector *b );
int isPointRightOfVector( const Vector *point, const Vector *vector );

void flipEdge( Edge *edge );
void edgeMiddle( const Edge *edge, Vector *result );
void edgeOffset( const Edge *edge, const Vector *offset, Edge *result );

void getPushedVector( const Edge *edgeA, const Edge *edgeB, const Vector *outsidePointA, const Vector *outsidePointB, REAL padding, Vector *out );

int lineIntersection( const Edge *edgeA, const Edge *edgeB, Vector *outResult );
