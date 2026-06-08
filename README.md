# TripoSR Docker Deployment

This repository provides a streamlined, CPU-only Docker deployment architecture for TripoSR. It is explicitly designed to facilitate the rapid generation of 3D models from single images in environments lacking CUDA-enabled GPUs.

This project manages the containerization, continuous integration, and resource allocation to ensure TripoSR runs efficiently and safely on host machines without causing memory exhaustion.

## Acknowledgements

The core artificial intelligence model and inference code utilized in this container are the property of the original researchers and developers. Full credit for the TripoSR model goes to [VAST-AI-Research and Stability AI](https://github.com/VAST-AI-Research/TripoSR). This repository serves strictly as an operational deployment wrapper for their open-source work.

## Architecture Overview

* **Base Image:** Built on `python:3.10-slim` to maintain a minimal footprint.
* **CPU Optimization:** PyTorch is installed exclusively with CPU wheels, bypassing heavy CUDA libraries. C++ compilers (`build-essential`, `ninja-build`) are included to compile `torchmcubes` during the CI/CD pipeline.
* **Persistent Caching:** Hugging Face model weights (approximately 4GB) are stored in a persistent Docker volume (`hf_cache`). This prevents the container from redownloading the model across restarts.
* **Resource Limits:** Hard memory limits are enforced via Docker configuration to prevent the AI model from consuming all available host RAM.

## Prerequisites

Before deploying, ensure the host machine meets the following requirements:

1. **Hardware:** Minimum of 8GB RAM (16GB recommended).
2. **Software:** Docker Engine and Docker Compose installed.
3. **For Docker Swarm Deployment Only:**
   * Swarm mode must be active (`docker swarm init`).
   * An external overlay network must be created beforehand.
     ```bash
     docker network create -d overlay default_network
     ```

## Configuration

Clone the repository and configure the environment variables:

```bash
git clone https://github.com/Claudao01/triposr-docker-deployment.git
cd triposr-docker-deployment
cp .env.example .env
```

Edit the `.env` file to match your infrastructure requirements. The `NETWORK_NAME` variable must perfectly match the name of the external network created in the Swarm prerequisites.

## Deployment Options

This repository supports two deployment methods depending on your infrastructure.

### Option A: Docker Swarm (Recommended for Production/Clusters)

This mode leverages `docker-swarm.yml` and requires the predefined external network. It offers high availability and automatic restarts.

```bash
# Ensure the deployment script is executable
chmod +x deploy.sh

# Run the deployment script with the swarm argument (default)
./deploy.sh swarm
```

### Option B: Standalone Docker Compose (Recommended for Local Testing)

This mode uses `docker-compose.yml`. It does not require Swarm initialization or external networks.

```bash
# Ensure the deployment script is executable
chmod +x deploy.sh

# Run the deployment script with the compose argument
./deploy.sh compose
```

## Usage and Interface

Once deployed, the container will initialize the Gradio web server.

1. Navigate to `http://localhost:7860` (or the port specified in your `.env` file) in any modern web browser.
2. Upload a single image featuring a clear subject.
3. Click "Generate". Processing time relies heavily on the host CPU and typically ranges from 30 to 60 seconds.
4. Download the output as a `.obj` or `.glb` file for use in 3D modeling software such as Blender.

## Continuous Integration (CI/CD)

This repository integrates GitHub Actions. Any commit pushed to the `main` branch triggers an automated workflow that:

1. Provisions a Linux environment.
2. Compiles necessary dependencies (including `torchmcubes`).
3. Builds the Docker image.
4. Publishes the image to the GitHub Container Registry (GHCR) as `ghcr.io/claudao01/triposr-docker-deployment:main`.

Users running the deployment script will automatically pull this pre-built image, ensuring rapid start times and eliminating the need for local compilation.