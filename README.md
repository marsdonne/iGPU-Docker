# ROCm on AMD iGPUs (780M) with Docker

This project provides a Dockerfile to enable **AMD Radeon 780M** (based on the `gfx1103` / RDNA3 architecture) for GPU acceleration with **AMD ROCm** within a Docker container. Since integrated GPUs (iGPUs) like the 780M are not always officially or smoothly supported by all ROCm versions, this setup uses **Ubuntu 22.04 LTS** as its base, a version that has proven more stable for this use case.

---

## Prerequisites

* **Host System:** Ubuntu 22.04 LTS (Jammy Jellyfish).
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

