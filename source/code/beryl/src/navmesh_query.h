#pragma once

#include "api.h"

void pathfinder( const BNavmesh *navmesh, const BVector *start, const BVector *end, BPath *outPath );
void projectPointOntoNavmesh( const BNavmesh *navmesh, const BVector *point, const BTriangle **outTriangle, BVector *outPoint );