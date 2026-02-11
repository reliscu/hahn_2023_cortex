#!/usr/bin/env bash

cd /mnt/lareaulab/reliscu/no_backup/NSF_GRFP/data/bulk/hahn_2023/cortex/raw

sra="/mnt/lareaulab/reliscu/programs/sratoolkit.3.0.7-ubuntu64/bin"

# Subset metadata to cortex samples

samples=($(awk -F',' '$(NF) ~ /cortex/ {print $1}' ../../SraRunTable.csv))

"${sra}/prefetch" --max-size 30G ${samples[@]} 

# Download fastqs (this takes a few hours)

nproc=1
i=0
for ea in "${samples[@]}"; do
    # {
        if [[ -f "${ea}/${ea}_1.fastq.gz" && -f "${ea}/${ea}_2.fastq.gz" ]]; then
            echo $ea fastqs already downloaded
                        
        else
            sra_file="${ea}/${ea}.sra" 
            echo downloading fastqs for $sra_file

            "${sra}/fasterq-dump" "$sra_file" --split-files \
                -e 15 -b 1G -c 1G -m 3G -O "${ea}" \
                >>"${ea}/fasterq.log" 2>&1 
                
            for fq in "${ea}/${ea}"*fastq; do 
                pigz -p 15 "$fq" >>"${ea}/fasterq.log" 2>&1
            done
        fi
    # }  &
    # (( ++i % nproc == 0 )) && wait
done
# wait

# Check that all fastq files are there:

for ea in "${samples[@]}"; do
    if [[ -s "${ea}/${ea}_1.fastq.gz" && -s "${ea}/${ea}_2.fastq.gz" ]]; then
        continue
    else 
        ls "$ea"
    fi
done

find -type f -name "*.sra" -exec rm {} \;

