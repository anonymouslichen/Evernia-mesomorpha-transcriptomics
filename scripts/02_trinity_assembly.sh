#!/bin/bash -l
#SBATCH --time=48:00:00
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=248g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-/path/to/project}"
FILTERED_READS_DIR="${FILTERED_READS_DIR:-${PROJECT_DIR}/filtered_reads}"
SAMPLES_FILE="${SAMPLES_FILE:-${FILTERED_READS_DIR}/samples.txt}"
SCRATCH_DIR="${SCRATCH_DIR:-/path/to/scratch/dir}"
CPU="${SLURM_NTASKS:-16}"
MAX_MEMORY="${MAX_MEMORY:-238G}"
# ================================================

cd "${FILTERED_READS_DIR}"

module load trinityrnaseq/2.14.0

Trinity --seqType fq \
        --max_memory "${MAX_MEMORY}" \
        --samples_file "${SAMPLES_FILE}" \
        --output "${SCRATCH_DIR}" \
        --CPU "${CPU}" \
        --no_distributed_trinity_exec
