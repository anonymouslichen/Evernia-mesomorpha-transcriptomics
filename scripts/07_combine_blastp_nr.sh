#!/bin/bash
# Combine all BLASTp nr .out files and extract TaxID column
# Input:  Per-query .out files from 06a_blastp_nr_array1.sh / 06b_blastp_nr_array2.sh
# Output: blastp_out, blastp_seqids, blastp_seqids_unique

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
BLASTP_DIR="${PROJECT_DIR}/blastp_output"
# ================================================

cd "${BLASTP_DIR}"

# Merge all per-query outputs into one file
cat *.out > blastp_out

# Extract TaxID column (col 3)
# Original notes: ~184,943,559 lines in blastp_out
awk '{ print $3}' blastp_out > blastp_seqids

# Extract unique TaxIDs
# NOTE: the original script used 'uniq -u', which keeps only lines that are
# completely non-repeated (appear exactly once). If the goal was all distinct
# TaxIDs regardless of count, use:  sort blastp_seqids | uniq > blastp_seqids_unique
# Original notes: ~152,046,335 lines in output
uniq -u blastp_seqids > blastp_seqids_unique
