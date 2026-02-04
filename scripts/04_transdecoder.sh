#!/bin/bash -l
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=msismall
#SBATCH --mem=100g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu


#Calculating open reading frames (ORFs) from Trinity assembly
module load trinotate

cd ~/Evernia_Transcriptomes/trinity_outputs

TransDecoder.LongOrfs -t trinity_full.Trinity.fasta

TransDecoder.Predict -t trinity_full.Trinity.fasta
