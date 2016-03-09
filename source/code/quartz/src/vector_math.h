#pragma once
#include "types.h"

typedef struct QVector
{
	REAL x;
	REAL y;
} QVector;

typedef struct QEdge
{
	QVector start;
	QVector end;
} QEdge;

int vectorEquals( const QVector *a, const QVector *b );
REAL vectorLength( const QVector *vector );
void vectorAdd( const QVector *a, const QVector *b, QVector *result );
void vectorSubtract( const QVector *a, const QVector *b, QVector *result );
void vectorNormalize( QVector *vector );
void vectorScale( QVector *vector, REAL scale );
REAL vectorCrossProduct( const QVector *a, const QVector *b );
int areVectorsColinear( const QVector *a, const QVector *b );
int isPointRightOfVector( const QVector *point, const QVector *vector );

void flipEdge( QEdge *edge );
void edgeMiddle( const QEdge *edge, QVector *result );
void edgeOffset( const QEdge *edge, const QVector *offset, QEdge *result );

void getPushedVector( const QEdge *edgeA, const QEdge *edgeB, const QVector *outsidePointA, const QVector *outsidePointB, REAL padding, QVector *out );

int lineIntersection( const QEdge *edgeA, const QEdge *edgeB, QVector *outResult );
