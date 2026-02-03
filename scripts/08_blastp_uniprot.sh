#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=1:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

cd ~/Evernia_Transcriptomes/trinity_outputs_2

module load sqlite

sqlite3 Trinotate_Evernia_Bacteria_2023.sqlite < uniprot_accession_sql.txt
