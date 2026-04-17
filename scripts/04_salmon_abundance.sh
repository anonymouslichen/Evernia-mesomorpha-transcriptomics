#!/bin/bash -l
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
SALMON_OUTPUT_DIR="${SALMON_OUTPUT_DIR:-${PROJECT_DIR}/salmon_output}"
FILTERED_READS_DIR="${FILTERED_READS_DIR:-${PROJECT_DIR}/filtered_reads}"
SAMPLES_FILE="${SAMPLES_FILE:-${FILTERED_READS_DIR}/samples.txt}"
ASSEMBLY_DIR="${ASSEMBLY_DIR:-${PROJECT_DIR}/trinity_output}"
TRANSCRIPTS="${TRANSCRIPTS:-${ASSEMBLY_DIR}/Trinity.fasta}"
GENE_TRANS_MAP="${GENE_TRANS_MAP:-${ASSEMBLY_DIR}/Trinity.fasta.gene_trans_map}"
TRINITY_UTIL="${TRINITY_UTIL:-/path/to/trinityrnaseq/util}" # Trinity utilities
# ================================================

module load trinityrnaseq/2.14.0
module load R

cd "${SALMON_OUTPUT_DIR}"

# Per-sample quantification
"${TRINITY_UTIL}/align_and_estimate_abundance.pl" \
        --seqType fq \
        --samples_file "${SAMPLES_FILE}" \
        --transcripts "${TRANSCRIPTS}" \
        --est_method salmon \
        --trinity_mode \
        --prep_reference
        
find dry_* vapor_* liquid_* -name "quant.sf" | tee quant_files.list

"${TRINITY_UTIL}/abundance_estimates_to_matrix.pl" \
    --est_method salmon \
    --out_prefix Trinity \
    --name_sample_by_basedir \
    --quant_files quant_files.list \
    --gene_trans_map "${GENE_TRANS_MAP}"
