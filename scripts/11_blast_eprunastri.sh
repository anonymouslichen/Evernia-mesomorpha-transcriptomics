#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=25g
#SBATCH --time=01:00:00
#SBATCH --array=1-99
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
BLASTP_EMESO_DIR="${PROJECT_DIR}/blastp_emeso/seq_files"
# Reference genome database path
EPRUNASTRI_DB="${EPRUNASTRI_DB:-/path/to/blast_databases/Evernia_prunastri_genome.fna}"
# ================================================

module load ncbi_toolkit/25.2.0

cd "${BLASTP_EMESO_DIR}"

RUN_ID=$(($SLURM_ARRAY_TASK_ID))
QUERY=$( ls *.$RUN_ID )

tblastn -query ${QUERY} -db "${EPRUNASTRI_DB}" -out ${QUERY}.out -evalue 0.001  -outfmt 6 -num_threads 8
