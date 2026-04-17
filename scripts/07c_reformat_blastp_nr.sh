#!/bin/bash
# Reformat combined BLASTp nr output into 6-column identifier table
# Run after 07_combine_blastp_nr.sh
# Input:  blastp_out  (3 columns: qseqid, evalue, staxid)
# Output: longest_isoform_blastp.txt  (no header; 6 columns: gene, iso, g, m, evalue, TaxID)
#         Read by 08_Transcript_Taxa_Identification.R

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
BLASTP_DIR="${PROJECT_DIR}/blastp_output"
# ================================================

# tr '.' '\t' splits the .p# M-number off the qseqid, giving 4 fields:
#   TRINITY_..._i1  p1  evalue  staxid
# awk then reconstructs iso (field1.field2) and gene (field1 minus _i# suffix)
cat "${BLASTP_DIR}/blastp_out" | \
  tr '.' '\t' | \
  awk -F '\t' 'OFS="\t" {split($1, a, "_i"); print a[1], $1"."$2, $1, $2, $3, $4}' \
  > longest_isoform_blastp.txt
