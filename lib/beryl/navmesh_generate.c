#include "navmesh_generate.h"
#include "api.h"
#include "types.h"
#include "vector_math.h"
#include <assert.h>
#include <float.h>
#include <stdlib.h>
#include <string.h>

#define MAX_MAP_OBSTACLES 500
#define MAX_MAP_OBSTACLE_VERTICES 500
#define MAX_NAVMESH_TRIANGLES 1000
#define MAX_NAVMESH_VERTICES (3 * MAX_NAVMESH_TRIANGLES)
#define OBSTACLE_THICKNESS_EPSILON 0.001

// INTERNALS

static int isContourClockwise(const gpc_vertex_list* contour) {
	REAL sum = 0;
	for (int vertexIndex = 0; vertexIndex < contour->num_vertices; vertexIndex++) {
		const gpc_vertex* const vertexA = &contour->vertex[vertexIndex];
		const gpc_vertex* const vertexB =
			&contour->vertex[(vertexIndex + 1) % contour->num_vertices];
		sum += (vertexB->x - vertexA->x) * (vertexB->y + vertexA->y);
	}
	return sum > 0;
}

static void padVertex(const BEdge* inEdgeA, const BEdge* inEdgeB, int clockwise, REAL padding,
					  BVector* outPaddedVertex) {
	BEdge edgeA, edgeB;
	edgeA = *inEdgeA;
	edgeB = *inEdgeB;
	assert(vectorEquals(&edgeA.end, &edgeB.start));

	BVector vectorA;
	BVector vectorB;
	edgeToVector(&edgeA, &vectorA);
	edgeToVector(&edgeB, &vectorB);

	*outPaddedVertex = edgeA.end;

	if (areVectorsColinear(&vectorA, &vectorB)) {
		BVector paddingVector;
		vectorNormal(&vectorA, !clockwise, &paddingVector);
		vectorNormalize(&paddingVector);
		vectorScale(&paddingVector, padding);
		vectorAdd(outPaddedVertex, &paddingVector, outPaddedVertex);
	} else {
		{
			BVector edgeNormal;
			vectorNormal(&vectorA, !clockwise, &edgeNormal);
			vectorNormalize(&edgeNormal);
			vectorScale(&edgeNormal, padding);
			edgeOffset(&edgeA, &edgeNormal, &edgeA);
		}
		{
			BVector edgeNormal;
			vectorNormal(&vectorB, !clockwise, &edgeNormal);
			vectorNormalize(&edgeNormal);
			vectorScale(&edgeNormal, padding);
			edgeOffset(&edgeB, &edgeNormal, &edgeB);
		}

		verify(lineIntersection(&edgeA, &edgeB, outPaddedVertex));
	}
}

static void makeQuadrilateralPolygon(BVector* cornerA, BVector* cornerB, BVector* cornerC,
									 BVector* cornerD, gpc_polygon* outPolygon) {
	outPolygon->num_contours = 1;
	outPolygon->contour = malloc(sizeof(gpc_vertex_list));
	outPolygon->hole = malloc(sizeof(int));
	outPolygon->hole[0] = 0;
	outPolygon->contour[0].num_vertices = 4;
	outPolygon->contour[0].vertex = malloc(4 * sizeof(gpc_vertex));
	outPolygon->contour[0].vertex[0].x = cornerA->x;
	outPolygon->contour[0].vertex[0].y = cornerA->y;
	outPolygon->contour[0].vertex[1].x = cornerB->x;
	outPolygon->contour[0].vertex[1].y = cornerB->y;
	outPolygon->contour[0].vertex[2].x = cornerC->x;
	outPolygon->contour[0].vertex[2].y = cornerC->y;
	outPolygon->contour[0].vertex[3].x = cornerD->x;
	outPolygon->contour[0].vertex[3].y = cornerD->y;
}

static int insertPointInTriangulationInput(REAL x, REAL y, BTriangulation* outTriangulation) {
	// TODO.optimization: This would be faster if we kept the array sorted
	for (int i = 0; i < outTriangulation->numberofpoints; i++) {
		const REAL* const point = &outTriangulation->pointlist[2 * i];
		if (point[0] == x && point[1] == y) {
			return i;
		}
	}
	REAL* const point = &outTriangulation->pointlist[2 * outTriangulation->numberofpoints];
	point[0] = x;
	point[1] = y;
	outTriangulation->numberofpoints += 1;
	return outTriangulation->numberofpoints - 1;
}

static void getPointWithinContour(const gpc_vertex_list* contour, BVector* outPoint) {
	const int numVertices = contour->num_vertices;
	assert(numVertices > 2);

	// Find a x coordinate within the contour's bounding box
	// which is not the x coordinate of any of the vertices
	{
		REAL minX = DBL_MAX;
		REAL minX2 = DBL_MAX;
		for (int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++) {
			const gpc_vertex* const vertex = &contour->vertex[vertexIndex];
			if (vertex->x < minX) {
				minX2 = minX;
				minX = vertex->x;
			} else if (vertex->x != minX && vertex->x < minX2) {
				minX2 = vertex->x;
			}
		}
		assert(minX != DBL_MAX);
		assert(minX2 != DBL_MAX);
		assert(minX < minX2);
		outPoint->x = (minX + minX2) / 2;
	}

	{
		BEdge vertical;
		vertical.start.x = outPoint->x;
		vertical.start.y = 0;
		vertical.end.x = outPoint->x;
		vertical.end.y = 1;
		{
			REAL minY = DBL_MAX;
			REAL minY2 = DBL_MAX;

			// Intersect the vertical going through x with all segments in the
			// contour Keeping the lowest two y coordinates of intersections
			for (int vertexIndex = 1; vertexIndex <= numVertices; vertexIndex++) {
				const gpc_vertex* const previousVertex = &contour->vertex[vertexIndex - 1];
				const gpc_vertex* const vertex = &contour->vertex[vertexIndex % numVertices];
				assert(outPoint->x != previousVertex->x);
				assert(outPoint->x != vertex->x);

				if ((previousVertex->x - outPoint->x) * (vertex->x - outPoint->x) >= 0) {
					continue;
				}

				BEdge edge;
				edge.start.x = previousVertex->x;
				edge.start.y = previousVertex->y;
				edge.end.x = vertex->x;
				edge.end.y = vertex->y;

				BVector intersection;
				verify(lineIntersection(&edge, &vertical, &intersection));

				if (intersection.y < minY) {
					minY2 = minY;
					minY = intersection.y;
				} else if (intersection.y != minY && intersection.y < minY2) {
					minY2 = intersection.y;
				}
			}
			assert(minY != DBL_MAX);
			assert(minY2 != DBL_MAX);
			assert(minY < minY2);

			// If our obstacles had no holes, we would just use ( minY + minY2 )
			// / 2. Since going so far away from minY may put us in the middle
			// of a hole, we make the bet that the obstacle is at least
			// OBSTACLE_THICKNESS_EPSILON thick and only go that far. This will
			// be correct as long as their is no hole within
			// OBSTACLE_THICKNESS_EPSILON units of minY.
			assert((minY2 - minY) > OBSTACLE_THICKNESS_EPSILON);
			outPoint->y = minY + OBSTACLE_THICKNESS_EPSILON;
		}
	}
}

// PUBLIC API

void mapToPolygonMap(const BMap* map, BPolygonMap* outPolygonMap) {
	memset(outPolygonMap, 0, sizeof(*outPolygonMap));
	outPolygonMap->x = map->x;
	outPolygonMap->y = map->y;
	outPolygonMap->width = map->width;
	outPolygonMap->height = map->height;
	outPolygonMap->numPolygons = map->numObstacles;

	assert(outPolygonMap->numPolygons < MAX_MAP_OBSTACLES);
	outPolygonMap->polygons = malloc(outPolygonMap->numPolygons * sizeof(gpc_polygon));

	for (int obstacleIndex = 0; obstacleIndex < map->numObstacles; obstacleIndex++) {
		const int numVertices = map->obstacles[obstacleIndex].numVertices;
		assert(numVertices > 2);
		assert(numVertices < MAX_MAP_OBSTACLE_VERTICES);

		gpc_vertex_list* obstacleContour = malloc(sizeof(gpc_vertex_list));
		obstacleContour->num_vertices = numVertices;
		obstacleContour->vertex = malloc(numVertices * sizeof(gpc_vertex));
		for (int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++) {
			gpc_vertex* const vertex = &obstacleContour->vertex[vertexIndex];
			vertex->x = map->obstacles[obstacleIndex].vertices[vertexIndex].x;
			vertex->y = map->obstacles[obstacleIndex].vertices[vertexIndex].y;
		}

		gpc_polygon* obstaclePolygon = &outPolygonMap->polygons[obstacleIndex];
		obstaclePolygon->contour = obstacleContour;
		obstaclePolygon->num_contours = 1;
		obstaclePolygon->hole = malloc(sizeof(int));
		obstaclePolygon->hole[0] = 0;
	}
}

void padPolygonMap(int padding, const BPolygonMap* inMap, BPolygonMap* outMap) {
	assert(inMap != outMap);

	memset(outMap, 0, sizeof(*outMap));
	outMap->x = inMap->x + padding;
	outMap->y = inMap->y + padding;
	outMap->width = inMap->width - 2 * padding;
	outMap->height = inMap->height - 2 * padding;
	outMap->numPolygons = inMap->numPolygons;
	outMap->polygons = malloc(inMap->numPolygons * sizeof(gpc_polygon));
	memset(outMap->polygons, 0, inMap->numPolygons * sizeof(gpc_polygon));

	for (int polygonIndex = 0; polygonIndex < inMap->numPolygons; polygonIndex++) {
		gpc_polygon* const inPolygon = &inMap->polygons[polygonIndex];
		gpc_polygon* const outPolygon = &outMap->polygons[polygonIndex];
		gpc_polygon_clip(GPC_UNION, outPolygon, inPolygon, outPolygon);

		for (int contourIndex = 0; contourIndex < inPolygon->num_contours; contourIndex++) {
			const gpc_vertex_list* const inContour = &inPolygon->contour[contourIndex];
			const int numVertices = inContour->num_vertices;
			assert(numVertices > 2);
			int isClockwise = isContourClockwise(inContour);
			if (inPolygon->hole[contourIndex]) {
				isClockwise = !isClockwise;
			}

			for (int vertexIndex = 0; vertexIndex < numVertices; vertexIndex++) {
				BEdge edgeA, edgeB, edgeC;
				edgeA.start.x = inContour->vertex[vertexIndex].x;
				edgeA.start.y = inContour->vertex[vertexIndex].y;
				edgeA.end.x = inContour->vertex[(vertexIndex + 1) % numVertices].x;
				edgeA.end.y = inContour->vertex[(vertexIndex + 1) % numVertices].y;
				edgeB.start = edgeA.end;
				edgeB.end.x = inContour->vertex[(vertexIndex + 2) % numVertices].x;
				edgeB.end.y = inContour->vertex[(vertexIndex + 2) % numVertices].y;
				edgeC.start = edgeB.end;
				edgeC.end.x = inContour->vertex[(vertexIndex + 3) % numVertices].x;
				edgeC.end.y = inContour->vertex[(vertexIndex + 3) % numVertices].y;

				BEdge paddedEdgeB;
				padVertex(&edgeA, &edgeB, isClockwise, padding, &paddedEdgeB.start);
				padVertex(&edgeB, &edgeC, isClockwise, padding, &paddedEdgeB.end);

				gpc_polygon paddingPolygon;
				makeQuadrilateralPolygon(&edgeB.start, &paddedEdgeB.start, &paddedEdgeB.end,
										 &edgeB.end, &paddingPolygon);

				gpc_polygon_clip(GPC_UNION, outPolygon, &paddingPolygon, outPolygon);

				gpc_free_polygon(&paddingPolygon);
			}
		}
	}
}

void polygonMapToTriangulation(BPolygonMap* map, BTriangulation* outTriangulation) {
	memset(outTriangulation, 0, sizeof(*outTriangulation));

	BTriangulation triangulationInput;
	memset(&triangulationInput, 0, sizeof(triangulationInput));

	gpc_polygon mapPolygon;
	BVector topLeft, topRight, bottomRight, bottomLeft;
	topLeft.x = map->x;
	topLeft.y = map->y;
	topRight.x = map->x + map->width;
	topRight.y = map->y;
	bottomRight.x = map->x + map->width;
	bottomRight.y = map->y + map->height;
	bottomLeft.x = map->x;
	bottomLeft.y = map->y + map->height;
	makeQuadrilateralPolygon(&topLeft, &topRight, &bottomRight, &bottomLeft, &mapPolygon);

	for (int obstacleIndex = 0; obstacleIndex < map->numPolygons; obstacleIndex++) {
		gpc_polygon_clip(GPC_DIFF, &mapPolygon, &map->polygons[obstacleIndex], &mapPolygon);
	}

	int maxPoints = 0;
	assert(mapPolygon.num_contours > 0);
	for (int contourIndex = 0; contourIndex < mapPolygon.num_contours; contourIndex++) {
		const gpc_vertex_list* const contour = &mapPolygon.contour[contourIndex];
		assert(contour->num_vertices > 2);
		maxPoints += contour->num_vertices;
		triangulationInput.numberofsegments += contour->num_vertices;
		if (mapPolygon.hole[contourIndex]) {
			triangulationInput.numberofholes++;
		}
	}

	triangulationInput.pointlist = malloc(maxPoints * 2 * sizeof(REAL));
	triangulationInput.segmentlist = malloc(triangulationInput.numberofsegments * 2 * sizeof(int));
	triangulationInput.holelist = malloc(triangulationInput.numberofholes * 2 * sizeof(REAL));

	triangulationInput.numberofpoints = 0;
	int numSegments = 0;
	int numHoles = 0;
	for (int contourIndex = 0; contourIndex < mapPolygon.num_contours; contourIndex++) {
		const gpc_vertex_list* const contour = &mapPolygon.contour[contourIndex];
		const int numVertices = contour->num_vertices;
		assert(numVertices > 2);
		for (int vertexIndex = 0; vertexIndex <= numVertices; vertexIndex++) {
			const gpc_vertex* const vertex = &contour->vertex[vertexIndex % numVertices];
			const int endPoint =
				insertPointInTriangulationInput(vertex->x, vertex->y, &triangulationInput);
			if (vertexIndex > 0) {
				const gpc_vertex* const previousVertex = &contour->vertex[vertexIndex - 1];
				const int startPoint = insertPointInTriangulationInput(
					previousVertex->x, previousVertex->y, &triangulationInput);
				int* const segment = &triangulationInput.segmentlist[2 * numSegments];
				segment[0] = startPoint;
				segment[1] = endPoint;
				numSegments++;
			}
		}
		if (mapPolygon.hole[contourIndex]) {
			BVector holePoint;
			getPointWithinContour(contour, &holePoint);
			REAL* const hole = &triangulationInput.holelist[2 * numHoles];
			hole[0] = holePoint.x;
			hole[1] = holePoint.y;
			numHoles++;
		}
	}

	assert(numSegments == triangulationInput.numberofsegments);
	assert(numHoles == triangulationInput.numberofholes);

	triangulate("pjenzq5Q", &triangulationInput, outTriangulation, NULL);

	trifree(triangulationInput.pointlist);
	trifree(triangulationInput.segmentlist);
	trifree(triangulationInput.holelist);

	gpc_free_polygon(&mapPolygon);
}

static void markConnectedComponent(const BNavmesh* navmesh, BTriangle* triangle, int marker) {
	if (triangle->connectedComponent == marker) {
		return;
	}

	triangle->connectedComponent = marker;
	for (int n = 0; n < 3; n++) {
		const int neighbour = triangle->neighbours[n];
		if (neighbour >= 0) {
			markConnectedComponent(navmesh, &navmesh->triangles[neighbour], marker);
		}
	}
}

static void computeConnectedComponents(BNavmesh* navmesh) {
	int marker = 0;
	for (int i = 0; i < navmesh->numTriangles; i++) {
		BTriangle* const triangle = &navmesh->triangles[i];
		if (triangle->connectedComponent < 0) {
			markConnectedComponent(navmesh, triangle, marker);
			marker++;
		}
	}
}

static int isNavmeshTriangleCCW(const BNavmesh* navmesh, const BTriangle* triangle) {
	const BVector* vertexA = &navmesh->vertices[triangle->vertices[0]];
	const BVector* vertexB = &navmesh->vertices[triangle->vertices[1]];
	const BVector* vertexC = &navmesh->vertices[triangle->vertices[2]];
	return isTriangleCCW(vertexA, vertexB, vertexC);
}

void triangulationToNavmesh(const struct triangulateio* triangleOutput, BNavmesh* outNavmesh) {
	assert(outNavmesh);
	assert(triangleOutput);

	memset(outNavmesh, 0, sizeof(*outNavmesh));
	assert(triangleOutput->numberofpoints < MAX_NAVMESH_VERTICES);
	assert(triangleOutput->numberoftriangles < MAX_NAVMESH_TRIANGLES);

	outNavmesh->numVertices = triangleOutput->numberofpoints;
	outNavmesh->numTriangles = triangleOutput->numberoftriangles;
	outNavmesh->triangles = malloc(outNavmesh->numTriangles * sizeof(BTriangle));
	outNavmesh->vertices = malloc(outNavmesh->numVertices * sizeof(BVector));

	for (int i = 0; i < outNavmesh->numVertices; i++) {
		outNavmesh->vertices[i].x = triangleOutput->pointlist[2 * i + 0];
		outNavmesh->vertices[i].y = triangleOutput->pointlist[2 * i + 1];
	}

	for (int i = 0; i < outNavmesh->numTriangles; i++) {
		BTriangle* const triangle = &outNavmesh->triangles[i];
		triangle->vertices[0] = triangleOutput->trianglelist[3 * i + 0];
		triangle->vertices[1] = triangleOutput->trianglelist[3 * i + 1];
		triangle->vertices[2] = triangleOutput->trianglelist[3 * i + 2];
		triangle->neighbours[0] = triangleOutput->neighborlist[3 * i + 0];
		triangle->neighbours[1] = triangleOutput->neighborlist[3 * i + 1];
		triangle->neighbours[2] = triangleOutput->neighborlist[3 * i + 2];
		triangle->center.x = 0;
		triangle->center.x += outNavmesh->vertices[outNavmesh->triangles[i].vertices[0]].x;
		triangle->center.x += outNavmesh->vertices[outNavmesh->triangles[i].vertices[1]].x;
		triangle->center.x += outNavmesh->vertices[outNavmesh->triangles[i].vertices[2]].x;
		triangle->center.y = 0;
		triangle->center.y += outNavmesh->vertices[outNavmesh->triangles[i].vertices[0]].y;
		triangle->center.y += outNavmesh->vertices[outNavmesh->triangles[i].vertices[1]].y;
		triangle->center.y += outNavmesh->vertices[outNavmesh->triangles[i].vertices[2]].y;
		vectorScale(&triangle->center, 1.f / 3.f);
		triangle->connectedComponent = -1;
		assert(isNavmeshTriangleCCW(outNavmesh, triangle));
	}

	computeConnectedComponents(outNavmesh);
}

void freePolygonMap(BPolygonMap* map) {
	for (int polygonIndex = 0; polygonIndex < map->numPolygons; polygonIndex++) {
		gpc_free_polygon(&map->polygons[polygonIndex]);
	}
	free(map->polygons);
	map->polygons = NULL;
}
