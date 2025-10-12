#!/bin/bash
export interval=$((10*1000*1000))
function run_gcpt() {
    OUTDIR=$1
    BIN=$2

         # --debug-flags=O3PipeView \
         # --debug-file=trace.out \
         # --debug-flags=Rename \
    build/RISCV/gem5.opt \
        --outdir=${OUTDIR} \
        ./configs/example/xiangshan.py \
        --mem-type=SimpleMemory \
        --num-cpus=1 --warmup-insts-no-switch ${interval}  -I $((2*interval)) \
        --generic-rv-cpt=${BIN} \
        --param="system.cpu[0].dumpStatsInterval=0" \
        --param="system.cpu[0].SbufferEvictThreshold=1" \
        --param="system.cpu[0].SbufferEntries=4" \
        --param="system.cpu[0].StoreBufferEnqueueWidth=2" \ # adjust this!
        --raw-cpt \

        # --param="system.cpu[0].StoreCompletionWidth=1" \
        # --gcpt-restorer=${GCPT_HOME} \
        # --difftest-ref-so=/home/qingxuan/work/xs-workspace/xs-env/xs-env/NEMU_ref/build/riscv64-nemu-interpreter-so \
        # --enable-difftest \
        # --param="system.cpu[0].rcvg_ld_reuse=True" \
        # --param="system.cpu[0].rcvg_mem_violation_flush=False" \
        # --param="system.cpu[0].rcvg_num_streams=${RCVG_NUM}" \
        # --param="system.cpu[0].rcvg_siz_streams=4096" \
}

export -f run_gcpt

# BIN="/home/qingxuan/work/xs-workspace/xs-env/xs-env/NEMU/output/checkpoint/h264ref_foreman.main/11233/_11233_0.035475_memory_.zstd"
# BIN="/home/qingxuan/work/xs-workspace/xs-env/xs-env/nexus-am/apps/mcs/build_9/mcs-riscv64-xs.bin"
# run_gcpt "TEST" ${BIN}

for i in 1 2 3 4 5 6 7 8 9; do
    BIN="/home/qingxuan/work/xs-workspace/xs-env/xs-env/nexus-am/apps/mcs/build_${i}/mcs-riscv64-xs.bin"
    run_gcpt "MCS_$i" ${BIN} &> /dev/null
    echo -n "$i "; grep "ipc" MCS_$i/stats.txt | head -1
done
