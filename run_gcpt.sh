#!/bin/bash
export interval=$((10*1000*1000))
function run_gcpt() {
    BASE=$1
    OUTDIR=$2
    BIN=$3

    ${BASE}/gem5.opt \
        --outdir=${OUTDIR} \
        ${BASE}/configs/example/xiangshan.py \
        --mem-type=SimpleMemory \
        --num-cpus=1 --warmup-insts-no-switch ${interval}  -I $((2*interval)) \
        --gcpt-restorer=${GCPT_HOME} \
        --generic-rv-cpt=${BIN} \

        # --difftest-ref-so=/home/qingxuan/work/xs-workspace/xs-env/xs-env/NEMU_ref/build/riscv64-nemu-interpreter-so \
        # --enable-difftest
        # --param="system.cpu[0].rcvg_enable=${RCVG_EN}" \
        # --param="system.cpu[0].rcvg_ld_reuse=True" \
        # --param="system.cpu[0].rcvg_mem_violation_flush=False" \
        # --param="system.cpu[0].rcvg_num_streams=${RCVG_NUM}" \
        # --param="system.cpu[0].rcvg_siz_streams=4096" \
}

export -f run_gcpt

# BIN="/home/qingxuan/work/xs-workspace/xs-env/xs-env/NEMU/output/checkpoint/astar_rivers/15503/_15503_0.154731_memory_.zstd"
# run_gcpt "TEST" ${BIN}

OUT_DIR_BASE=$1
CPT_DIR="/home/qingxuan/work/xs-workspace/xs-env/xs-env/NEMU/output/checkpoint/"
BINS=$(ls ${CPT_DIR}/h264ref_foreman.main*/*/*.zstd)
OUT_DIR=$(for f in ${BINS}; do echo "${OUT_DIR_BASE}/$(basename $(dirname $(dirname "$f")))_$(basename $(dirname "$f"))"; done)

mkdir -p $OUT_DIR_BASE
cp build/RISCV/gem5.opt $OUT_DIR_BASE
cp -r configs $OUT_DIR_BASE

parallel -j 70 --joblog "joblog.txt" --link run_gcpt {1} {2} {3} ::: $OUT_DIR_BASE ::: $OUT_DIR ::: $BINS
