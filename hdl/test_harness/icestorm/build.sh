#!/bin/bash

SRC_DIR=../src
COMMON_SRC_DIR=../../common/src

yosys -p "synth_ice40 -blif test_harness.blif" $SRC_DIR/test_harness_wrapper.v $SRC_DIR/controller.v $SRC_DIR/demodulator.v $SRC_DIR/mem_manager.v $SRC_DIR/modulator.v $SRC_DIR/msg_asm.v $SRC_DIR/msg_disasm.v $SRC_DIR/pll.v $SRC_DIR/replace_num_mem.v $SRC_DIR/shift_register.v $SRC_DIR/test_harness.v $SRC_DIR/uart_rx.v $SRC_DIR/uart_tx.v $COMMON_SRC_DIR/power_on_reset.v $COMMON_SRC_DIR/fifo.v $COMMON_SRC_DIR/dual_port_ram.v


