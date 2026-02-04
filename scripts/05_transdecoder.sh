#!/bin/bash -l
# Predict ORFs with TransDecoder; split peptide FASTA for parallel BLASTp
# Input:  trinity_full.Trinity.fasta
# Output: longest_orfs.pep split into 3000 files for array BLASTp jobs (steps 06a/06b)

#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
# Set these paths before running
PROJECT_DIR="${PROJECT_DIR:-~/my_project}"
ASSEMBLY_DIR="${PROJECT_DIR}/trinity_output"
ASSEMBLY_FASTA="${ASSEMBLY_DIR}/Trinity.fasta"
# GenomeTools path for splitfasta
GT_BIN="${GT_BIN:-~/bin/genometools-1.6.2/bin/gt}"
# ================================================

module load trinotate

cd "${ASSEMBLY_DIR}"

# Identify candidate ORFs
TransDecoder.LongOrfs -t "${ASSEMBLY_FASTA}"

# Predict likely coding regions
TransDecoder.Predict -t "${ASSEMBLY_FASTA}"

# Split .pep output into 3000 files for parallel array BLASTp
"${GT_BIN}" splitfasta -numfiles 3000 longest_orfs.pep
