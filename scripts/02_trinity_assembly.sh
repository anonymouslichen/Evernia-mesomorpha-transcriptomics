#!/bin/bash -l
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=agsmall
#SBATCH --mem=300g
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

cd ~/Evernia_Transcriptomes/starting_files_2/ribodetector

module load trinityrnaseq/2.14.0

srun Trinity --CPU 8 --max_memory 285G --grid_exec "~/bin/HpcGridRunner-1.0.2/hpc_cmds_GridRunner.pl --grid_conf ~/jobs/SLURM.conf -c" --seqType fq --samples_file starting_file_round2_ribodepleted.txt  --output /scratch.global/meye2099/trinity_full
