#!/bin/bash -l

#SBATCH --job-name=code-analyzer-gradio
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=/scratch/users/%u/mambapy-gradio-%j.out
#SBATCH --error=/scratch/users/%u/mambapy-gradio-%j.err

set -e

export PYTHONNOUSERSITE=1
export GRADIO_SERVER_PORT=7860

echo "========================================"
echo "Unified Code Analyzer - Gradio"
echo "========================================"

echo
echo "Compute node:"
hostname

echo
echo "Slurm job information:"
echo "Job ID                  : ${SLURM_JOB_ID:-not-set}"
echo "Node                    : ${SLURMD_NODENAME:-$(hostname)}"
echo "CUDA_VISIBLE_DEVICES    : ${CUDA_VISIBLE_DEVICES:-not-set}"
echo "Gradio port             : $GRADIO_SERVER_PORT"

# --------------------------------------------------
echo
echo "========================================"
echo "GPU"
echo "========================================"

if ! command -v nvidia-smi >/dev/null 2>&1; then
   echo
   echo "ERROR: nvidia-smi is not available."
   echo "The job will not continue."
   exit 1
fi

nvidia-smi

# --------------------------------------------------
echo
echo "========================================"
echo "Loading CUDA"
echo "========================================"

module load cuda

echo
echo "CUDA module loaded."

# --------------------------------------------------
echo
echo "========================================"
echo "Python environment"
echo "========================================"

cd "$HOME/Code-Analyzer"

if [ ! -f "$HOME/venvs/bin/activate" ]; then
   echo
   echo "ERROR: Python virtual environment not found:"
   echo "$HOME/venvs/bin/activate"
   exit 1
fi

. "$HOME/venvs/bin/activate"

echo
echo "Python:"
python --version

echo
echo "Python executable:"
which python

echo
echo "Virtual environment:"
echo "${VIRTUAL_ENV:-not-set}"

if [ "$(which python)" != "$HOME/venvs/bin/python" ]; then
   echo
   echo "ERROR: ~/venvs is not active."
   echo
   echo "Expected:"
   echo "$HOME/venvs/bin/python"
   echo
   echo "Found:"
   echo "$(which python)"
   exit 1
fi

# --------------------------------------------------
echo
echo "========================================"
echo "PyTorch"
echo "========================================"

python -c "
import torch

print('PyTorch:', torch.__version__)
print('PyTorch CUDA:', torch.version.cuda)
print('GPU count:', torch.cuda.device_count())
"

# --------------------------------------------------
echo
echo "========================================"
echo "Checking Gradio port"
echo "========================================"

if command -v ss >/dev/null 2>&1; then
   if ss -ltn | grep -q ":${GRADIO_SERVER_PORT} "; then
      echo
      echo "ERROR: Port $GRADIO_SERVER_PORT is already in use."
      echo "Node: $(hostname)"
      echo
      ss -ltnp | grep ":${GRADIO_SERVER_PORT} " || true
      exit 1
   fi
fi

echo "Port $GRADIO_SERVER_PORT is available."

# --------------------------------------------------
echo
echo "========================================"
echo "Checking application"
echo "========================================"

if [ ! -f "$HOME/Code-Analyzer/app.py" ]; then
   echo
   echo "ERROR: app.py was not found."
   echo "$HOME/Code-Analyzer/app.py"
   exit 1
fi

echo "Application found:"
echo "$HOME/Code-Analyzer/app.py"

# --------------------------------------------------
echo
echo "========================================"
echo "Starting Gradio"
echo "========================================"

echo
echo "Compute node:"
hostname

echo
echo "Slurm Job ID:"
echo "${SLURM_JOB_ID:-not-set}"

echo
echo "Gradio port:"
echo "$GRADIO_SERVER_PORT"

# --------------------------------------------------
echo
echo "========================================"
echo "Windows tunnel command"
echo "========================================"

echo

echo "for /f \"delims=\" %N in ('ssh -m hmac-sha2-512 ${USER}@hpc.create.kcl.ac.uk \"squeue -j $SLURM_JOB_ID -h -o %%N\"') do ssh -m hmac-sha2-512 -N -L 7860:%N:7860 ${USER}@hpc.create.kcl.ac.uk"

echo
echo "Then open:"
echo
echo "http://localhost:7860"

echo
echo "========================================"
echo "Running Unified Code Analyzer"
echo "========================================"

echo

python app.py
# --------------------------------------------------

