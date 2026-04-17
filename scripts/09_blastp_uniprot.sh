#!/bin/bash
# BLASTp predicted peptides vs. UniProt (release 2023_01) for functional annotation
# Array job structured identically to 06a_blastp_nr_array1.sh / 06b_blastp_nr_array2.sh
# Input:  Split .pep files from 05_transdecoder.sh
# Output: Per-query .out files → combine downstream to produce longest_isoform_gene_identification.csv
#         (read by 10_Gene_Function_Identification.R)

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=50g
#SBATCH --time=30:00:00
#SBATCH --array=1-1500
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
BLASTP_DIR="${PROJECT_DIR}/blastp_uniprot"
# UniProt database path (release 2023_01 used in publication)
UNIPROT_DB="${UNIPROT_DB:-/path/to/uniprot/uniprot_sprot}"
# ================================================

module load ncbi_blast+

cd "${BLASTP_DIR}"

RUN_ID=$(($SLURM_ARRAY_TASK_ID))
QUERY=$( ls *.$RUN_ID )

blastp -query ${QUERY} \
       -db "${UNIPROT_DB}" \
       -out ${QUERY}.out \
       -evalue 0.001 \
       -outfmt "6 qseqid evalue staxid" \
       -num_threads 8
