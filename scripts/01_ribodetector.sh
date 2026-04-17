#!/bin/bash -l
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=20
#SBATCH --threads-per-core=1
#SBATCH --tmp=850g
#SBATCH --mem=50g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-/path/to/project}"
RAW_READS_DIR="${RAW_READS_DIR:-${PROJECT_DIR}/raw_reads}"
FILTERED_READS_DIR="${FILTERED_READS_DIR:-${PROJECT_DIR}/filtered_reads}"
READ_LENGTH="${READ_LENGTH:-150}" 
CHUNK_SIZE="${CHUNK_SIZE:-1000}" 
THREADS="${SLURM_CPUS_PER_TASK:-20}"
# ================================================

module load parallel

cd "${RAW_READS_DIR}"

conda activate ribodetector

fun () {
    local file1="$1"
    local file2="${file1/R1/R2}"
    local sample
    sample="$(echo "$file1" | awk -F "_" '{print $1 "_" $2}')"
 
    local out_R1="${sample}_R1_ribodepleted.fastq.gz"
    local out_R2="${sample}_R2_ribodepleted.fastq.gz"
 
    ribodetector_cpu \
        -t "${THREADS}" \
        -l "${READ_LENGTH}" \
        -i "${file1}" "${file2}" \
        -e rrna \
        --chunk_size "${CHUNK_SIZE}" \
        -o "${FILTERED_READS_DIR}/${out_R1}" "${FILTERED_READS_DIR}/${out_R2}"
}
export -f fun
 
parallel -j 1 --compress fun {} ::: *R1*
