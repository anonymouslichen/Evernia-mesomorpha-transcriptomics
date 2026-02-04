#!/bin/bash -l
# Trinity de novo assembly — Phase 1
# Input:  Paired-end FASTQ files (rRNA-filtered), samples file
# Output: Partial assembly in scratch directory (continued by 03_trinity_phase2.sh)
# Ref:    Meyer et al. 2024, Sci. Adv. 10, eado2783

#SBATCH --time=48:00:00
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=248g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
FILTERED_READS_DIR="${PROJECT_DIR}/filtered_reads"
SAMPLES_FILE="${FILTERED_READS_DIR}/samples.txt"
SCRATCH_DIR="${SCRATCH_DIR:-/path/to/scratch/dir}"
# ================================================

cd "${FILTERED_READS_DIR}"

module load trinityrnaseq/2.14.0

Trinity --seqType fq \
        --max_memory 238G \
        --samples_file "${SAMPLES_FILE}" \
        --output "${SCRATCH_DIR}" \
        --CPU 16 \
        --no_distributed_trinity_exec
