#
#	Memory GUI makefile
#	Josh Tyler June 2017
#
CC=g++
CFLAGS=-c -g  -Wall -I ftdi_wrapper/ -I uart_msg/ -I /usr/include/libftdi1/
LDFLAGS= -lftdi1
SOURCES=ftdi_wrapper/ftdi_wrapper.cpp mem_gui.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=mem_gui

all: $(SOURCES) $(EXECUTABLE)
    
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	/bin/rm $(OBJECTS) $(EXECUTABLE)
