#!/bin/bash -l
# Trinity de novo assembly — Phase 2 (distributed via HpcGridRunner)
# Requires config/SLURM.conf for grid job submission
# Input:  Partial assembly from 02_trinity_assembly.sh
# Output: trinity_full.Trinity.fasta

#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=50g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
FILTERED_READS_DIR="${PROJECT_DIR}/filtered_reads"
SAMPLES_FILE="${FILTERED_READS_DIR}/samples.txt"
SCRATCH_DIR="${SCRATCH_DIR:-/path/to/scratch/dir}"
# HpcGridRunner paths
GRID_RUNNER="${GRID_RUNNER:-~/bin/HpcGridRunner-1.0.2/hpc_cmds_GridRunner.pl}"
GRID_CONF="${GRID_CONF:-~/jobs/SLURM.conf}"
# ================================================

cd "${FILTERED_READS_DIR}"

module load trinityrnaseq/2.14.0

srun Trinity --CPU 1 \
             --max_memory 45G \
             --grid_exec "${GRID_RUNNER} --grid_conf ${GRID_CONF} -c" \
             --seqType fq \
             --samples_file "${SAMPLES_FILE}" \
             --output "${SCRATCH_DIR}"
