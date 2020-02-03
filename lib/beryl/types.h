#pragma once

#ifdef SINGLE // Update Lua FFI if changing this
#define REAL float
#else /* not SINGLE */
#define REAL double
#endif /* not SINGLE */

#ifndef NDEBUG
#define verify(x) assert(x)
#else
#define verify(x) ((void)(x))
#endif
