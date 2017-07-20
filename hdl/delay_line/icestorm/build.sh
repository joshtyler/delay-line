#!/bin/bash

SRC_DIR=../src
COMMON_SRC_DIR=../../common/src
OUT_NAME=delay_line

echo "Begin synthesis"

yosys -p "synth_ice40 -blif $OUT_NAME.blif" $SRC_DIR/delay_line_wrapper.v $SRC_DIR/delay_line.v $SRC_DIR/comparator.v $SRC_DIR/edge_detect.v $SRC_DIR/pll.v $SRC_DIR/pulse_gen.v $COMMON_SRC_DIR/power_on_reset.v $COMMON_SRC_DIR/fifo.v > yosys.log

# Print yosys warnings
echo "Yosys warnings:"
cat yosys.log | grep -i "warning"
echo "Yosys errors:"

echo "Begin PNR"
# We don't generate a log for arachne-pnr because it prints to stderr (annoyingly)
# Instead the user can just read this manually

arachne-pnr -d 1k -p $SRC_DIR/icestick.pcf $OUT_NAME.blif -o $OUT_NAME.asc

icepack $OUT_NAME.asc $OUT_NAME.bin
