#!/bin/bash -l
# *** PLACEHOLDER — replace with your actual script ***
#
# BLASTp predicted peptides against UniProt for gene functional annotation.
# From paper: UniProt release 2023_01, E-value threshold 0.001.
#             Best-hit filtering by symbiont kingdom happens in R (step 10).
# Input:  Longest-isoform peptide sequences (from TransDecoder output)
# Output: longest_isoform_gene_identification.csv
#           (read by 10_Gene_Function_Identification.R)
#
# Note: was this also run as a SLURM array job like the nr BLASTp (steps 06a/06b)?

#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
ASSEMBLY_DIR="${PROJECT_DIR}/trinity_output"
BLASTP_OUTPUT_DIR="${PROJECT_DIR}/blastp_uniprot"
# UniProt database path
UNIPROT_DB="${UNIPROT_DB:-/path/to/uniprot/uniprot_sprot}"
# ================================================

# TODO: add your UniProt BLASTp command(s) here
