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
REAL vectorLength2( const QVector *vector );
REAL vectorDistance2( const QVector *a, const QVector *b );
void vectorAdd( const QVector *a, const QVector *b, QVector *result );
void vectorMadd( const QVector *a, REAL m, const QVector *b, QVector *result );
void vectorSubtract( const QVector *a, const QVector *b, QVector *result );
void vectorNormalize( QVector *vector );
void vectorScale( QVector *vector, REAL scale );
void vectorNormal( const QVector *vector, int left, QVector *outNormal );
REAL vectorDotProduct( const QVector *a, const QVector *b );
REAL vectorCrossProduct( const QVector *a, const QVector *b );
int areVectorsColinear( const QVector *a, const QVector *b );

void edgeOffset( const QEdge *edge, const QVector *offset, QEdge *result );
void edgeToVector( const QEdge *edge, QVector *vector );

int lineIntersection( const QEdge *edgeA, const QEdge *edgeB, QVector *outResult );
void projectPointOntoSegment( const QVector *vector, const QEdge *line, QVector *outResult );
