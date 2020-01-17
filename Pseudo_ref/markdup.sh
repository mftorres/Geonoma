#!/bin/bash
#SBATCH -A $PROJECT_ID
#SBATCH -J Geo_pseduo_markdup
#SBATCH -N 1
#SBATCH -t 5-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

echo "Starting at `date`"

module load icc/2018.3.222-GCC-7.3.0-2.30  impi/2018.3.222;
module load SAMtools/1.9;
module load GCC/8.3.0
module load BWA/0.7.17

### samtools and picard do not do parallelization, better use 1 node
### each node has 12 cores, take 10 and leave 2 for sync/summ
### define variables

COMP_DIR='~/pfs';
DATA_DIR='/proj/nobackup/$PROJECT_ID';

SAMPLE=$(ls $DATA_DIR/trimmed/P13454_10${SLURM_ARRAY_TASK_ID}_trimmed.1.fastq.gz | sed -r 's/_trimmed.1.fastq.gz//g');
echo $SAMPLE;

### map reads to reference to create sam/bam

bwa mem -t 20 $DATA_DIR/reference/GCF_000442705.1_EG5_genomic.fna ${SAMPLE}_trimmed.1.fastq.gz ${SAMPLE}_trimmed.2.fastq.gz -o "${SAMPLE}".sam $2> bwa_markdup_%J.err;

samtools view -bS -T $DATA_DIR/reference/GCF_000442705.1_EG5_genomic.fna ${SAMPLE}.sam > "${SAMPLE}".bam;
rm ${SAMPLE}.sam;

samtools sort -n ${SAMPLE}.bam -o "${SAMPLE}".sorted.bam;

# check read files have the same headers and number of reads
samtools fixmate -m ${SAMPLE}.sorted.bam "${SAMPLE}".sorted.fixmate.bam;
samtools sort ${SAMPLE}.sorted.fixmate.bam -o "${SAMPLE}".sorted.fixmate.position.bam;

# remove PCR duplicates. File is too large to keep the reads flagged, I'm trying to reduce it by force-removing duplicates 
samtools markdup -r ${SAMPLE}.sorted.fixmate.position.bam "${SAMPLE}".sorted.fixmate.position.markdup.bam;

# index bam
samtools index ${SAMPLE}.sorted.fixmate.position.markdup.bam;

# stats
samtools flagstat ${SAMPLE}.sorted.fixmate.position.markdup.bam > "${SAMPLE}".mappingstats.txt;

# remove middle files
rm ${SAMPLE}.sorted.bam ${SAMPLE}.sorted.fixmate.bam ${SAMPLE}.sorted.fixmate.position.bam;

mv ${SAMPLE}.*markdup.bam $DATA_DIR/markdup/
mv ${SAMPLE}.mappingstats* $DATA_DIR/markdup/

echo "Program finished with exit code $? at: `date`"
