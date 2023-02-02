echo "parameters"
echo "   1: what to run (adult, airbnb etc.). This call = " $1
echo "   2: new train_percent value. This call = " $2
echo "   3: new runs value. This call = " $3
echo "   4: an index used to differentiate subruns. This call = " $4

mkdir results

sbatch -J $2_$3-$4_$1 run_something.slurm $1 $2 $3 $4
