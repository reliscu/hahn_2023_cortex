``#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate star

cd /mnt/lareaulab/reliscu/no_backup/NSF_GRFP/data/bulk/hahn_2023/cortex/trimmed

# Run STAR to get alignments and splice junction counts 

index_dir="/mnt/lareaulab/reliscu/data/GENCODE/GRCm39/STAR_150_index"
gtf="/mnt/lareaulab/reliscu/data/GENCODE/GRCm39/gencode.vM35.annotation.gtf"

samples=($(find . -type d ! -name "." -printf '%P\n'))

for ea in "${samples[@]}"; do
    echo
    echo $ea

    # Using ENCODE settings
    STAR \
        --runThreadN 15 \
        --genomeDir $index_dir \
        --sjdbGTFfile $gtf \
        --sjdbOverhang 149 \
        --readFilesCommand zcat \
        --readFilesIn "${ea}/${ea}_val_1.fq.gz" "${ea}/${ea}_val_2.fq.gz" \
        --outSAMtype BAM SortedByCoordinate \
        --outFileNamePrefix "../processed/STAR/${ea}/" \
        --twopassMode Basic \
        --quantMode GeneCounts \
        --outFilterMultimapNmax 20 \
        --alignSJDBoverhangMin 1 \
        --outFilterMismatchNmax 999 \
        --outFilterMismatchNoverReadLmax 0.4 \
        --alignIntronMin 20 \
        --alignIntronMax 1000000 \
        --alignMatesGapMax 1000000
done


