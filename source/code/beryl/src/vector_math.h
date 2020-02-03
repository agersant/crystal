#pragma once
#include "types.h"

typedef struct BVector {
	REAL x;
	REAL y;
} BVector;

typedef struct BEdge {
	BVector start;
	BVector end;
} BEdge;

int vectorEquals(const BVector* a, const BVector* b);
REAL vectorLength(const BVector* vector);
REAL vectorLength2(const BVector* vector);
REAL vectorDistance(const BVector* a, const BVector* b);
REAL vectorDistance2(const BVector* a, const BVector* b);
void vectorAdd(const BVector* a, const BVector* b, BVector* result);
void vectorMadd(const BVector* a, REAL m, const BVector* b, BVector* result);
void vectorSubtract(const BVector* a, const BVector* b, BVector* result);
void vectorNormalize(BVector* vector);
void vectorScale(BVector* vector, REAL scale);
void vectorNormal(const BVector* vector, int left, BVector* outNormal);
REAL vectorDotProduct(const BVector* a, const BVector* b);
REAL vectorCrossProduct(const BVector* a, const BVector* b);
int areVectorsColinear(const BVector* a, const BVector* b);

void edgeOffset(const BEdge* edge, const BVector* offset, BEdge* result);
void edgeToVector(const BEdge* edge, BVector* vector);

int lineIntersection(const BEdge* edgeA, const BEdge* edgeB, BVector* outResult);
void projectPointOntoSegment(const BVector* vector, const BEdge* line, BVector* outResult);
void projectPointOntoTriangle(const BVector* a, const BVector* b, const BVector* c,
							  const BVector* p, BVector* outPoint);

int isTriangleCCW(const BVector* a, const BVector* b, const BVector* c);
int doesTriangleContainPoint(const BVector* a, const BVector* b, const BVector* c,
							 const BVector* point);
