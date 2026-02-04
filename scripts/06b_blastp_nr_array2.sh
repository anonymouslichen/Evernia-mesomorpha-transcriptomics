#!/bin/bash
# BLASTp vs. NCBI nr — Array job Part 2 (tasks 1501–2990)
# Input:  Split .pep files from 05_transdecoder.sh
# Output: Per-query .out files; combined downstream in 07_combine_blastp_nr.sh

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=50g
#SBATCH --time=30:00:00
#SBATCH --array=1-1490
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
BLASTP_DIR="${PROJECT_DIR}/blastp_output"
# NCBI nr database path (adjust for your cluster)
NR_DB="${NR_DB:-/path/to/blast/nr}"
# ================================================

module load ncbi_blast+

cd "${BLASTP_DIR}"

RUN_ID=$(($SLURM_ARRAY_TASK_ID + 1500))
QUERY=$( ls *.$RUN_ID )

blastp -query ${QUERY} \
       -db "${NR_DB}" \
       -out ${QUERY}.out \
       -evalue 0.001 \
       -outfmt "6 qseqid evalue staxid" \
       -num_threads 8
