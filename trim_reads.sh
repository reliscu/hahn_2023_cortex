#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate star

cd /mnt/lareaulab/reliscu/no_backup/NSF_GRFP/data/bulk/hahn_2023/cortex/raw

# I need to remove Nextera adapters. Using trim-galore (like the authors):

#################################################################################

# First test with one sample

ea=SRR21355662
outdir="../trimmed/${ea}/"
in1="${ea}/${ea}_1.fastq.gz"
in2="${ea}/${ea}_2.fastq.gz"

trim_galore --paired --length 20 --phred33 --q 30 --nextera --cores 8 \
    --basename "$ea" -o "$outdir" "$in1" "$in2"

fastqc ../trimmed/${ea}/*.fq.gz

#################################################################################

samples=($(find . -type d ! -name "." -printf '%P\n'))

nproc=5
i=0
for ea in "${samples[@]}"; do
    {
        echo
        echo "$ea"
        outdir="../trimmed/${ea}"
        in1="${ea}/${ea}_1.fastq.gz"
        in2="${ea}/${ea}_2.fastq.gz"

        if [[ ! -f "${outdir}/${ea}_val_1.fq.gz" || ! -f "${outdir}/${ea}_val_2.fq.gz" ]]; then
            trim_galore --paired --length 20 --phred33 --q 30 --nextera --cores 5 \
                --basename "$ea" -o "$outdir/" "$in1" "$in2"
        fi
    } &
    (( ++i % nproc == 0)) && wait
done
wait
