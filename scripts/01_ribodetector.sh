#!/bin/bash -l
#SBATCH --time=5:00:00
#SBATCH --partition=agsmall
#SBATCH --cpus-per-task=20
#SBATCH --threads-per-core=1
#SBATCH --tmp=850g
#SBATCH --mem=50g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meye2099@umn.edu

module load parallel

cd ~/Evernia_Transcriptomes/starting_files_2/Stanton_Project_005

conda activate ribodetector

fun () {
  file1="$1"
	file2=`echo $file1 | awk -F "R1" '{print $1 "R2" $2}'`
  out_name_R1=`echo $file1 | awk -F "_" '{print $1 "_" $2 "_" "R1_ribodepleted.fastq.gz"}'`
  out_name_R2=`echo $file2 | awk -F "_" '{print $1 "_" $2 "_" "R2_ribodepleted.fastq.gz"}'`
  ribodetector_cpu -t 20 \
    -l 150 \
    -i $file1 $file2 \
    -e rrna \
    --chunk_size 1000 \
    -o ../ribodetector_parallel/$out_name_R1 ../ribodetector_parallel/$out_name_R2
}
export -f fun

parallel -j 1 --compress fun {} ::: *R1*
