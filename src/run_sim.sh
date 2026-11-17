#!/bin/sh
# Compila e simula o sistema completo com GHDL.
# Uso: ./run_sim.sh [N]     (N padrao = 8)
N=${1:-8}
mkdir -p build && cd build || exit 1
ghdl -a --std=08 ../src/register_bank.vhd ../src/merge_comparator.vhd \
    ../src/merge_datapath.vhd ../src/merge_control.vhd ../src/merge_sort.vhd \
    ../testbench/tb_merge_sort.vhd || exit 1
ghdl -e --std=08 tb_merge_sort || exit 1
ghdl -r --std=08 tb_merge_sort -gNUM_ELEMENTOS=$N --wave=merge_sort.ghw


# EXEMPLO DE TESTE COM ARQUIVO SEPARADO:
# cd build
# ghdl -a --std=08 ../src/merge_comparator.vhd ../testbench/tb_merge_comparator.vhd
# ghdl -e --std=08 tb_merge_comparator
# ghdl -r --std=08 tb_merge_comparator