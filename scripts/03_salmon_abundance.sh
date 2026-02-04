#!/bin/bash -l
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --partition=agsmall
#SBATCH --mail-user=meye2099@umn.edu

module load trinityrnaseq/2.14.0
module load R

cd ~/Evernia_Transcriptomes/salmon_3

#Done in two parts, the first instance did not finish. Changed samples_file to include just Liquid 3-5. Reduced time from 30:00:00.
#/panfs/roc/msisoft/trinityrnaseq/2.14.0/util/align_and_estimate_abundance.pl --seqType fq \
    --samples_file ~/Evernia_Transcriptomes/starting_files_2/ribodetector/starting_file_round2_ribodepleted2.txt \
    --transcripts ~/Evernia_Transcriptomes/trinity_outputs_2/Trinity.tmp.fasta  \
    --est_method salmon  --trinity_mode  --prep_reference

find dry_* vapor_* liquid_* -name "quant.sf" | tee quant_files.list

/panfs/roc/msisoft/trinityrnaseq/2.14.0/util/abundance_estimates_to_matrix.pl --est_method salmon \
    --out_prefix Trinity --name_sample_by_basedir \
    --quant_files quant_files.list \
    --gene_trans_map ~/Evernia_Transcriptomes/trinity_outputs_2/Trinity.tmp.fasta.gene_trans_map
