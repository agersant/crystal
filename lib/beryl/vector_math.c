#include "vector_math.h"
#include <assert.h>
#include <math.h>

#define B_EPSILON 1E-8

static REAL clamp(REAL low, REAL value, REAL high) {
	return value > high ? high : value < low ? low : value;
}

int vectorEquals(const BVector* a, const BVector* b) {
	return a->x == b->x && a->y == b->y;
}

REAL vectorLength(const BVector* vector) {
	return sqrt((vector->x * vector->x) + (vector->y * vector->y));
}

REAL vectorLength2(const BVector* vector) {
	return (vector->x * vector->x) + (vector->y * vector->y);
}

REAL vectorDistance(const BVector* a, const BVector* b) {
	BVector difference;
	vectorSubtract(a, b, &difference);
	return vectorLength(&difference);
}

REAL vectorDistance2(const BVector* a, const BVector* b) {
	BVector difference;
	vectorSubtract(a, b, &difference);
	return vectorLength2(&difference);
}

void vectorAdd(const BVector* a, const BVector* b, BVector* result) {
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void vectorMadd(const BVector* a, REAL m, const BVector* b, BVector* result) {
	result->x = a->x + m * b->x;
	result->y = a->y + m * b->y;
}

void vectorSubtract(const BVector* a, const BVector* b, BVector* result) {
	result->x = a->x - b->x;
	result->y = a->y - b->y;
}

void vectorNormalize(BVector* vector) {
	REAL length = vectorLength(vector);
	assert(length > 0);
	vector->x /= length;
	vector->y /= length;
}

void vectorScale(BVector* vector, REAL scale) {
	vector->x *= scale;
	vector->y *= scale;
}

void vectorNormal(const BVector* vector, int left, BVector* outNormal) {
	outNormal->x = -vector->y;
	outNormal->y = vector->x;
	if (left) {
		vectorScale(outNormal, -1);
	}
}

REAL vectorDotProduct(const BVector* a, const BVector* b) {
	return a->x * b->x + a->y * b->y;
}

REAL vectorCrossProduct(const BVector* a, const BVector* b) {
	return a->x * b->y - a->y * b->x;
}

int areVectorsColinear(const BVector* a, const BVector* b) {
	return vectorCrossProduct(a, b) == 0;
}

void edgeOffset(const BEdge* edge, const BVector* offset, BEdge* result) {
	vectorAdd(&edge->start, offset, &result->start);
	vectorAdd(&edge->end, offset, &result->end);
}

void edgeToVector(const BEdge* edge, BVector* vector) {
	vector->x = edge->end.x - edge->start.x;
	vector->y = edge->end.y - edge->start.y;
}

int lineIntersection(const BEdge* edgeA, const BEdge* edgeB, BVector* outResult) {
	const REAL x1 = edgeA->start.x;
	const REAL y1 = edgeA->start.y;
	const REAL x2 = edgeA->end.x;
	const REAL y2 = edgeA->end.y;
	const REAL x3 = edgeB->start.x;
	const REAL y3 = edgeB->start.y;
	const REAL x4 = edgeB->end.x;
	const REAL y4 = edgeB->end.y;
	const REAL det = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if (det == 0) {
		return 0;
	}
	outResult->x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / det;
	outResult->y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / det;
	return 1;
}

void projectPointOntoSegment(const BVector* point, const BEdge* line, BVector* outResult) {
	assert(!vectorEquals(&line->start, &line->end));
	BVector AB, AP;
	vectorSubtract(&line->end, &line->start, &AB);
	vectorSubtract(point, &line->start, &AP);
	const REAL length2 = vectorLength2(&AB);
	const REAL t = vectorDotProduct(&AB, &AP) / length2;
	vectorMadd(&line->start, t, &AB, outResult);
}

int doesTriangleContainPoint(const BVector* a, const BVector* b, const BVector* c,
							 const BVector* p) {
	BVector ab, bc, ca, ap, bp, cp;
	vectorSubtract(b, a, &ab);
	vectorSubtract(c, b, &bc);
	vectorSubtract(a, c, &ca);
	vectorSubtract(p, a, &ap);
	vectorSubtract(p, b, &bp);
	vectorSubtract(p, c, &cp);

	REAL abx = vectorCrossProduct(&ab, &ap);
	REAL bcx = vectorCrossProduct(&bc, &bp);
	REAL cax = vectorCrossProduct(&ca, &cp);

	if (fabs(abx) <= B_EPSILON) {
		abx = 0.f;
	}

	if (fabs(bcx) <= B_EPSILON) {
		bcx = 0.f;
	}

	if (fabs(cax) <= B_EPSILON) {
		cax = 0.f;
	}

	return (abx >= 0 && bcx >= 0 && cax >= 0) || (abx <= 0 && bcx <= 0 && cax <= 0);
}

int isTriangleCCW(const BVector* a, const BVector* b, const BVector* c) {
	BVector ab, ac;
	vectorSubtract(b, a, &ab);
	vectorSubtract(c, a, &ac);
	return vectorCrossProduct(&ac, &ab) < 0;
}

// Based on http://wonderfl.net/c/b27F
void projectPointOntoTriangle(const BVector* a, const BVector* b, const BVector* c,
							  const BVector* p, BVector* outPoint) {
	assert(isTriangleCCW(a, b, c));

	BVector AB, AP, BC, BP, CA, CP;
	vectorSubtract(b, a, &AB);
	vectorSubtract(p, a, &AP);
	vectorSubtract(c, b, &BC);
	vectorSubtract(p, b, &BP);
	vectorSubtract(a, c, &CA);
	vectorSubtract(p, c, &CP);

	const REAL abx = vectorCrossProduct(&AB, &AP);
	const REAL bcx = vectorCrossProduct(&BC, &BP);
	const REAL cax = vectorCrossProduct(&CA, &CP);

	if (abx < 0 && bcx >= 0 && cax < 0) {
		*outPoint = *a;
	} else if (abx < 0 && bcx < 0 && cax >= 0) {
		*outPoint = *b;
	} else if (abx >= 0 && bcx < 0 && cax < 0) {
		*outPoint = *c;
	} else if (abx < 0 && bcx >= 0 && cax >= 0) {
		const REAL t = clamp(0, vectorDotProduct(&AB, &AP) / vectorLength2(&AB), 1);
		vectorMadd(a, t, &AB, outPoint);
	} else if (abx >= 0 && bcx < 0 && cax >= 0) {
		const REAL t = clamp(0, vectorDotProduct(&BC, &BP) / vectorLength2(&BC), 1);
		vectorMadd(b, t, &BC, outPoint);
	} else if (abx >= 0 && bcx >= 0 && cax < 0) {
		const REAL t = clamp(0, vectorDotProduct(&CA, &CP) / vectorLength2(&CA), 1);
		vectorMadd(c, t, &CA, outPoint);
	} else {
		*outPoint = *p;
	}

	assert(doesTriangleContainPoint(a, b, c, outPoint));
}
