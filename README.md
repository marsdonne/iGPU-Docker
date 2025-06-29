# ROCm on AMD iGPUs (780M) with Docker

This project provides a Dockerfile to enable **AMD Radeon 780M** (based on the `gfx1103` / RDNA3 architecture) for GPU acceleration with **AMD ROCm** within a Docker container. Since integrated GPUs (iGPUs) like the 780M are not always officially or smoothly supported by all ROCm versions, this setup uses **Ubuntu 22.04 LTS** as its base, a version that has proven more stable for this use case.

---

## Prerequisites

* **Docker:** A working Docker installation on your host system.
* **AMDGPU Driver:** The corresponding AMDGPU kernel modules must be correctly installed and active on your host system for Docker containers to access `/dev/kfd` and `/dev/dri`.
* **Local `rocm-pin.pref` file:** A file named `rocm-pin.pref` in the same directory as the Dockerfile with the following content:
    ```
    Package: *
    Pin: release o=repo.radeon.com, n=jammy
    Pin-Priority: 600
    ```
    (Note: `n=jammy` is relevant here for Ubuntu 22.04 LTS).

---

## Usage

### 1. Build the Docker Image

Navigate to the directory containing your `Dockerfile` and `rocm-pin.pref` file in your terminal, then run the build command.

```bash
docker build -t rocm-igpu:latest .
```

### 2. Run the Docker Container
To allow the container to access your AMD iGPU, you need to pass through the relevant devices and set the group permissions correctly.

```bash
docker run -it --rm \
--device=/dev/kfd \
--device=/dev/dri \
--group-add=$(getent group render | cut -d: -f3) \
--group-add=$(getent group video | cut -d: -f3) \
rocm-igpu:latest
```

This command will start an interactive Bash shell inside the container.

---

### 3. Test ROCm Functionality in the Container

Test ROCm Functionality in the Container
Once you are inside the container's shell, you can verify the ROCm installation with the following commands:

- `rocminfo`: Displays detailed information about the GPU recognized by ROCm. 
- `clinfo`: Lists all recognized OpenCL platforms and devices.
- `rocm-smi`: Provides information on GPU utilization and status (temperature, memory usage, etc.).

If these commands correctly recognize your GPU and provide output, ROCm is successfully configured in your Docker container and ready for GPU-accelerated applications.

### 4. Testing PyTorch with GPU Acceleration

To test the GPU acceleration functionality with PyTorch, you can use the provided `Dockerfile.pytorch-test`. This Dockerfile builds on the `rocm-base` image and installs PyTorch with ROCm support.

**Dockerfile:** `Dockerfile.pytorch`
**Test script:** `test_gpu.py`

1.  **Ensure `test_gpu.py` is present:**
    Make sure the `test_gpu.py` script (provided earlier) is in the same directory as your `Dockerfile.pytorch`.

2.  **Build the PyTorch test image:**
    Navigate to your project directory in the terminal and build the image.
    ```bash
    docker build -f Dockerfile.pytorch -t rocm-pytorch-test:latest .
    ```

3.  **Run the PyTorch test container:**
    Start the container, ensuring GPU devices and group permissions are passed through.
    ```bash
    docker run -it --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    --group-add=$(getent group render | cut -d: -f3) \
    --group-add=$(getent group video | cut -d: -f3) \
    rocm-pytorch-test:latest
    ```

4.  **Verify the output:**
    The container is configured to automatically run `test_gpu.py` upon startup. You should see output similar to this, confirming GPU availability and a successful computation:

    ```
    PyTorch Version: X.Y.Z+rocm...
    Is CUDA (ROCm) available? True
    Number of GPUs: 1
    Current GPU: AMD Radeon Graphics (gfx1103)  # Or similar for your 780M

    Successfully performed a matrix multiplication on the GPU.
    Result shape: torch.Size([1000, 1000])
    ```

    If `Is CUDA (ROCm) available? False` or an error occurs, review your ROCm base image setup and Docker run commands.
