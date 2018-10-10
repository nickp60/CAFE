OS := $(shell uname)
ifeq ($(OS) ,Darwin)
# Run MacOS commands
CC = cc
CFLAGS = -std=c99 -pedantic -Wall
OBJECTS = seg_clus.o

all: seg_clus

seg_clus.o: seg_clus.c
	$(CC) $(CFLAGS) -c seg_clus.c

seg_clus: $(OBJECTS)
	$(CC) $(OBJECTS) -o seg_clus

clean:
	rm -f *.o seg_clus
else
# check for Linux and run other commands
seg_clus: seg_clus.c
# gcc -pg seg_clus.c -lm -o seg_clus # for profiling
	gcc -g seg_clus.c -lm -o seg_clus
endif
