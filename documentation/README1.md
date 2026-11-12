## 1) Running Via Gradio Web Interface

The Gradio interface can be used to:

- Select the model version
- Select LoRA or full model
- Enter Mamba/Python/Java code
- Run the analyze program
- View detected flaws
- View refactored versions
- View inference information

The following instructions describe how to run the application on a remote GPU/HPC provider and access the Gradio interface from your local computer.

> **Important:** The commands for requesting GPU resources, activating environments, and connecting to compute nodes depend on your HPC/GPU provider. The examples below use **SLURM**, which is commonly used on HPC systems. A KCL-specific example is provided where applicable.

---

#### 1. Connect to the GPU/HPC Provider

From your local computer, connect to the remote GPU/HPC server using SSH:

```bash
ssh -m hmac-sha2-512 USERNAME@HPC_HOST
```

Replace:

* `USERNAME` with your account username on the HPC/GPU provider.
* `HPC_HOST` with the hostname of the remote HPC/GPU server.

For example:

```bash
ssh -m hmac-sha2-512 username@hpc.example.org
```

After connecting successfully, you should see a shell prompt on the HPC login node, similar to:

```bash
username@hpc-login:~$
```

> **Note:** You must have an account and SSH access to the HPC/GPU provider before running this command. The hostname, username, authentication method, and SSH options may differ between providers.

**KCL example:**

For users of the KCL CREATE HPC system, the connection may look like:

```bash
ssh -m hmac-sha2-512 k12345@hpc.create.kcl.ac.uk
```

---

#### 2. Go to the Project Directory

Move into the Code-Analyzer project:

```bash
cd ~/Code-Analyzer
```

Check that the project is there:

```bash
ls
```

You should see files such as:

```text
analyze.py
app.py
input/
...
```

You can also check your current directory:

```bash
pwd
```

> **Note:** The project directory may be different depending on where you cloned or copied the project.

---

#### 3. Verify the Input File Exists

Check the input file:

```bash
ls -lh input/sample.txt
```

or:

```bash
ls -lh input/sample.py
```

or:

```bash
ls -lh input/sample.java
```

You can also inspect the input file:

```bash
cat input/sample.txt
```

or:

```bash
cat input/sample.py
```

or:

```bash
cat input/sample.java
```

---

#### 4. Request a GPU Resource

If your HPC provider uses SLURM, request a GPU resource.

For example:

```bash
srun --partition=gpu \
     --gres=gpu:1 \
     --time=04:00:00 \
     --cpus-per-task=4 \
     --mem=32G \
     --pty /bin/bash -l
```

The exact command depends on your HPC provider. The partition name, GPU specification, time limit, CPU allocation, and memory requirements may be different.

After the resources have been allocated, SLURM may display something similar to:

```text
srun: job 12345678 has been allocated resources
```

The number `12345678` is the **SLURM job ID**. Keep this number because it can be used later when creating the SSH tunnel.

Check that the GPU is available:

```bash
nvidia-smi
```

If required by your HPC provider, load CUDA:

```bash
module load cuda
```

> **KCL example:** The SLURM command above is suitable as an example for a KCL CREATE environment, but users should follow the current resource requirements and partition configuration provided by their HPC administrator.

---

#### 5. Activate the Python Virtual Environment

Activate the Python virtual environment:

```bash
. ~/venvs/bin/activate
```

Check the Python version:

```bash
python --version
```

Check where Python is coming from:

```bash
which python
```

It should point to a Python executable inside your virtual environment, for example:

```text
/home/username/venvs/bin/python
```

> **Note:** The location of the virtual environment may be different on your system. Use the virtual environment created for the project.

---
#### 6. Run the Gradio Application

Start the Gradio application on the HPC compute node:

```bash
python app.py
```

The application should start on the port configured in `app.py`.

For example:

```text
* Running on local URL: http://0.0.0.0:7860
```

In this example, the application uses port `7860`.

Keep this HPC terminal open while using the application.

---

#### 7. Create an SSH Tunnel

To access the Gradio application from your local computer, you need to create an SSH tunnel between your Windows computer and the HPC compute node.

Open a **second Command Prompt (CMD) window on your local Windows computer**.

The SSH tunnel forwards a local port on your computer to the port where the Gradio application is running on the HPC compute node.

You can identify the compute node using either the SLURM job ID or the SLURM job name.

**Important:** The following commands use Windows Command Prompt (CMD), not PowerShell. For KCL HPC, the `-m hmac-sha2-512` option is used to specify the SSH MAC algorithm required by the connection configuration.

### Option A: Use the SLURM Job ID (Recommended)

If you know your SLURM job ID, use:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 USERNAME@HPC_HOST "squeue -j JOB_ID -h -o %%N"') do ssh -m hmac-sha2-512 -N -L LOCAL_PORT:%N:REMOTE_PORT USERNAME@HPC_HOST
```

Replace:

- `USERNAME` → Your HPC username.
- `HPC_HOST` → Your HPC login hostname.
- `JOB_ID` → Your numeric SLURM job ID.
- `LOCAL_PORT` → The port on your local computer.
- `REMOTE_PORT` → The port used by the Gradio application.

**Example:**

Suppose:
- HPC username: `k12345`
- HPC hostname: `hpc.create.kcl.ac.uk`
- SLURM job ID: `37241627`
- Local port: `7860`
- Gradio port: `7860`

The command becomes:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 k12345@hpc.create.kcl.ac.uk "squeue -j 37241627 -h -o %%N"') do ssh -m hmac-sha2-512 -N -L 7860:%N:7860 k12345@hpc.create.kcl.ac.uk
```

This command automatically:
1. Connects to the HPC login node.
2. Retrieves the compute node assigned to the specified SLURM job.
3. Establishes an SSH tunnel forwarding local port `7860` to port `7860` on the allocated compute node.

### Option B: Use the SLURM Job Name

Alternatively, you can identify your job using its SLURM job name with the `-n` option:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 USERNAME@HPC_HOST "squeue -n \"JOB_NAME\" -h -o %%N"') do ssh -m hmac-sha2-512 -N -L LOCAL_PORT:%N:REMOTE_PORT USERNAME@HPC_HOST
```

For example, if your SLURM job name is `Jupyter Lab`:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 k12345@hpc.create.kcl.ac.uk "squeue -n \"Jupyter Lab\" -h -o %%N"') do ssh -m hmac-sha2-512 -N -L 7860:%N:7860 k12345@hpc.create.kcl.ac.uk
```

**Recommendation:** Using the numeric SLURM job ID with `-j` is preferable because it avoids ambiguity when multiple jobs have similar names.

**Important:** If you put these commands in a Windows `.bat` file rather than typing them directly into CMD, replace `%N` with `%%N`.

---

#### 8. Open the Gradio Application

After establishing the SSH tunnel, keep both terminals open:

1. The HPC terminal running `python app.py`.
2. The local Windows CMD terminal maintaining the SSH tunnel.

Open your web browser on your local computer and navigate to:

```text
http://localhost:7860
```

Your Gradio application should now be accessible through your local browser.

**Note:** If you close either terminal, the application or SSH tunnel will stop working. Make sure that the SLURM job remains active while using the application.
