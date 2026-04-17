#!/bin/bash -l
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=50g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-/path/to/project}"
FILTERED_READS_DIR="${PROJECT_DIR}/filtered_reads"
SAMPLES_FILE="${FILTERED_READS_DIR}/samples.txt"
SCRATCH_DIR="${SCRATCH_DIR:-/path/to/scratch/dir}"
# HpcGridRunner paths
GRID_RUNNER="${GRID_RUNNER:-~/bin/HpcGridRunner-1.0.2/hpc_cmds_GridRunner.pl}"
GRID_CONF="${GRID_CONF:-~/jobs/SLURM.conf}"
# Trinity resource settings
CPU="${SLURM_NTASKS:-1}"
MAX_MEMORY="${MAX_MEMORY:-45G}"
# ================================================

cd "${FILTERED_READS_DIR}"

module load trinityrnaseq/2.14.0

srun Trinity --CPU "${CPU}" \
             --max_memory "${MAX_MEMORY}" \
             --grid_exec "${GRID_RUNNER} --grid_conf ${GRID_CONF} -c" \
             --seqType fq \
             --samples_file "${SAMPLES_FILE}" \
             --output "${SCRATCH_DIR}"
