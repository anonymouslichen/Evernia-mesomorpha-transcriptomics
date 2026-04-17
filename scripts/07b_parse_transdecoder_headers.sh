#!/bin/bash
# Parse TransDecoder peptide headers into tab-separated identifier table
# Run after 05_transdecoder.sh
# Input:  longest_orfs.pep  (TransDecoder output)
# Output: transdecoder_ORF_IDs.txt  (no header; 4 columns: gene, iso, g, len)
#         Read by 08_Transcript_Taxa_Identification.R

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
ASSEMBLY_DIR="${PROJECT_DIR}/trinity_output"
PEP_FILE="${ASSEMBLY_DIR}/longest_orfs.pep"
# ================================================

grep "^>" "${PEP_FILE}" | \
  cut -c 2- | \
  tr ':' '\t' | \
  cut -f1,3,5,13 | \
  awk -F '[\t ]' 'OFS="\t" {print $1, $2, $3, $4}' \
  > transdecoder_ORF_IDs.txt
