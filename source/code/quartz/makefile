CC ?= clang

CFLAGS = -shared -fPIC -Wall -DLINUX
TARGET = quartz.so
OBJS = api.o linked_list.o navmesh_generate.o navmesh_query.o vector_math.o triangle.o gpc.o

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

gpc.o : ../../../lib/gpc/gpc.c
	$(CC) $(CFLAGS) $< -o $@
	
triangle.o : ../../../lib/triangle/triangle.c
	$(CC) $(CFLAGS) $< -o $@
	
%.o : src/%.c
	$(CC) $(CFLAGS) $< -o $@
