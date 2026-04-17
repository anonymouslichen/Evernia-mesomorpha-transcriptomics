#!/bin/bash -l
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

# ============== USER CONFIGURATION ==============
PROJECT_DIR="${PROJECT_DIR:-/path/to/project}"
ASSEMBLY_DIR="${ASSEMBLY_DIR:-${PROJECT_DIR}/trinity_output}"
ASSEMBLY_FASTA="${ASSEMBLY_FASTA:-${ASSEMBLY_DIR}/Trinity.fasta}"
# GenomeTools — used for splitting the protein FASTA
# Install: http://genometools.org/pub/
GT_BIN="${GT_BIN:-/path/to/genometools}"
# Number of files to split the protein fasta file into for parallel BLASTp (step 06)
NUM_SPLITS="${NUM_SPLITS:-3000}"
# ================================================

module load trinotate

cd "${ASSEMBLY_DIR}"

# Identify candidate ORFs
TransDecoder.LongOrfs -t "${ASSEMBLY_FASTA}"

# Predict likely coding regions
TransDecoder.Predict -t "${ASSEMBLY_FASTA}"

# Output from TransDecoder
PEP_FILE="longest_orfs.pep"

# Split .pep output into specified number of files for array BLASTp
"${GT_BIN}" splitfasta -numfiles "${NUM_SPLITS}" "${PEP_FILE}"
