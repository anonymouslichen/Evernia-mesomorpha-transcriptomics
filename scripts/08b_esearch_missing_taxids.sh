#!/bin/bash -l
# Fetch taxonomy XML for TaxIDs that taxonomizr could not resolve
# Run after 08_Transcript_Taxa_Identification.R writes TaxID_NA.txt
# Input:  TaxID_NA.txt (written by 08_Transcript_Taxa_Identification.R)
# Output: TaxID_NA_esearch.txt (tab-separated; reshaped in 08c_reformat_esearch_taxa.R)

#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@institution.edu

cd ~/edirect

cat TaxID_NA.txt | while read line
do
  efetch -db taxonomy -id ${line} -format xml | \
  xtract -pattern Taxon -first TaxId -element Taxon -block "*/Taxon" \
  -unless Rank -equals "no rank" -tab "," -sep "_" -element Rank,ScientificName
done > TaxID_NA_esearch.txt
