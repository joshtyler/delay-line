#!/bin/bash

SRC_DIR=../src

iverilog -o fifo.vvp test_fifo.v $SRC_DIR/fifo.v
vvp fifo.vvp -lxt2
