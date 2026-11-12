## 3) Running Using KCL CREATE HPC Workflow with Gradio

We provide an optional KCL CREATE script to run the project in an HPC/GPU environment using a Gradio interface.

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

```
analyze.py
app.py
input/
...
```

You can also check your current directory:

```bash
pwd
```
---
#### 3. Verify the Input File Exists

Check the input file:

```bash
ls -lh input/sample.txt
or
ls -lh input/sample.py
or
ls -lh input/sample.java
```

You can also test:

```bash
cat input/sample.txt
or
cat input/sample.py
or
cat input/sample.java
```

---

#### 4. Check the SLURM Script and Make the Script Executable

Run:

```bash
cat KCL/run_kcl_gradio.sh
```

Then:

```bash
chmod +x KCL/run_kcl_gradio.sh
```

Check the file:

```bash
ls -l KCL/run_kcl_gradio.sh
```

You should see executable permissions, for example:

```
-rwxr-xr-x ... run_kcl_gradio.sh
```
---

#### 5. Submit the SLURM Job

Submit the script using:

```bash
sbatch KCL/run_kcl_gradio.sh
```

You should receive something similar to:

```
Submitted batch job 12345678
```

The number is the **JOBID**. For example:

```
JOBID=12345678
```

Your JOBID will be different each time you submit a new job.

Wait until the job is running:

```bash
squeue -j 12345678
```
Your output will look like:
```bash
JOBID       PARTITION   NAME           USER    ST   NODELIST
12345678    gpu         CodeAnalyzer   ...     R    gpu-node-42
```

---

#### 6. Open the SSH Tunnel

Now go to your Windows PC and open a **second Command Prompt (CMD) window**.

Use the **JOBID obtained in Step 5** to identify the compute node running your SLURM job and establish an SSH tunnel to the Gradio application.

The general command is:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 USERNAME@HPC_HOST "squeue -j JOB_ID -h -o %%N"') do ssh -m hmac-sha2-512 -N -L LOCAL_PORT:%N:REMOTE_PORT USERNAME@HPC_HOST
```

Replace:

- `USERNAME` → Your HPC username.
- `HPC_HOST` → Your HPC login hostname.
- `JOB_ID` → The numeric SLURM job ID obtained in Step 5.
- `LOCAL_PORT` → The port on your local computer (e.g., `7860`).
- `REMOTE_PORT` → The port used by the Gradio application (e.g., `7860`).

**Example:**

Suppose your JOBID is:

```text
12345678
```

and the Gradio application uses port `7860`. The command becomes:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 USERNAME@HPC_HOST "squeue -j 12345678 -h -o %%N"') do ssh -m hmac-sha2-512 -N -L 7860:%N:7860 USERNAME@HPC_HOST
```

**KCL example:**

If your KCL username is `k12345`, your HPC hostname is `hpc.create.kcl.ac.uk`, and your JOBID is `12345678`, use:

```cmd
for /f "delims=" %N in ('ssh -m hmac-sha2-512 k12345@hpc.create.kcl.ac.uk "squeue -j 12345678 -h -o %%N"') do ssh -m hmac-sha2-512 -N -L 7860:%N:7860 k12345@hpc.create.kcl.ac.uk
```

**How does this command work?**

1. The first SSH command connects to the KCL HPC login node.
2. `squeue -j 12345678 -h -o %%N` retrieves the compute-node hostname assigned to your SLURM job.
3. The Windows `for /f` command stores the returned hostname in the variable `%N`.
4. The second SSH command establishes the tunnel, forwarding local port `7860` to port `7860` on the allocated compute node.

**Important:**

- When using `squeue -j`, provide **only the numeric JOBID**. Do not include the job name.

  Incorrect:

  ```bash
  squeue -j Jupyter Lab 12345678
  ```

  Correct:

  ```bash
  squeue -j 12345678
  ```

- The option `-m hmac-sha2-512` specifies the SSH MAC algorithm used for the KCL connection.
- The command is intended for Windows CMD, not PowerShell.
- When the tunnel is established, the CMD window may appear to do nothing. This is normal. Keep it open while using the Gradio application.
- Make sure your SLURM job is still running.

---

#### 7. Open Gradio in Your Browser

Once the SSH tunnel is established, open Chrome, Edge, Firefox, or another web browser on your local computer.

Navigate to:

```text
http://localhost:7860
```

The Gradio interface should now appear in your browser.

**Note:** Keep both the HPC terminal running `python app.py` and the Windows CMD window maintaining the SSH tunnel open while using the application.

---
