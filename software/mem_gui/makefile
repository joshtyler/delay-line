#
#	Memory GUI makefile
#	Josh Tyler June 2017
#
CC=g++
CFLAGS=-c -Wall -I ftdi/
LDFLAGS=
SOURCES=ftdi/ftdi.cpp mem_gui.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=mem_gui

all: $(SOURCES) $(EXECUTABLE)
    
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@ -lftdi
