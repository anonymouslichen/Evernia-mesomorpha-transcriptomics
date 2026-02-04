#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=25g
#SBATCH --time=01:00:00
#SBATCH --array=1-99
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

module load ncbi_toolkit/25.2.0

cd ~/Evernia_Transcriptomes/blastp_E.meso/seq_files

RUN_ID=$(($SLURM_ARRAY_TASK_ID))
QUERY=$( ls *.$RUN_ID )

tblastn -query ${QUERY} -db ~/Evernia_Transcriptomes/blast_databases/Evernia_prunastridb/Evernia_prunastri_genome.fna -out ${QUERY}.out -evalue 0.001  -outfmt 6 -num_threads 8
