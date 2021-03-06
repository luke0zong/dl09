#!/bin/bash

#SBATCH --gres=gpu:1
#SBATCH --partition=n1s8-t4-1
#SBATCH --account=dl09
#SBATCH --time=1:00:00
#SBATCH --output=dl09_eval_%j.out
#SBATCH --error=dl09_eval_%j.err
#SBATCH --exclusive
#SBATCH --requeue
#SBATCH --job-name=dl09_eval

/share/apps/local/bin/p2pBandwidthLatencyTest > /dev/null 2>&1

set -x

mkdir /tmp/$USER
export SINGULARITY_CACHEDIR=/tmp/$USER

cp -rp /scratch/DL21SP/student_dataset.sqsh /tmp
echo "Dataset is copied to /tmp"

cd $HOME/dl09/src

echo "Output log in $SCRATCH/log/eval_${SLURM_JOB_ID}.log"
tail -F $HOME/dl09/scripts/dl09_eval_${SLURM_JOB_ID}.out >> $SCRATCH/log/$eval_{SLURM_JOB_ID}.log &


singularity exec --nv \
--bind /scratch \
--overlay /scratch/DL21SP/conda_fixed.sqsh:ro \
--overlay /tmp/student_dataset.sqsh:ro \
/share/apps/images/cuda11.1-cudnn8-devel-ubuntu18.04.sif \
/bin/bash -c "
source /ext3/env.sh
conda activate dev
python eval.py --checkpoint-path $SCRATCH/model.pth
"
