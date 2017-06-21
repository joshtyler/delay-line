#
#	Memory GUI makefile
#	Josh Tyler June 2017
#
CC=g++
CFLAGS=-c -Werror -Wall -I /usr/include/libftdi1/
LDFLAGS=-lftdipp1
SOURCES=serial.cpp mem_gui.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=mem_gui

all: $(SOURCES) $(EXECUTABLE)
    
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@
