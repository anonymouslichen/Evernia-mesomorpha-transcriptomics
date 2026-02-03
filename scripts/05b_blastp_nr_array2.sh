#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=25g
#SBATCH --time=2:00:00
#SBATCH --array=1-1497
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

module load ncbi_toolkit/25.2.0

cd ~/Evernia_Transcriptomes/trinity_outputs_2/blastp

RUN_ID=$(($SLURM_ARRAY_TASK_ID + 1500))
QUERY=$( ls *.$RUN_ID )

blastp -query ${QUERY} -db /panfs/roc/msisoft/trinotate/4.0.0/data_dir/uniprot_sprot.pep -out ${QUERY}.out -evalue 0.001  -outfmt 6 -num_threads 8
