#!/bin/bash -l
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=50g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

cd ~/Evernia_Transcriptomes/blastp.pep_2

#combine all outputs into one file
cat *.out > blastp_out

#save file of just seqids > 184943559 lines
awk '{ print $3}' blastp_out > blastp_seqids

#save file of only unique seqids > 152046335 lines
uniq -u blastp_seqids > blastp_seqids_unique
