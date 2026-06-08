# TripoSR Docker Deployment

This repository provides a streamlined Docker deployment setup for TripoSR, optimized to run entirely on CPU. It is designed to facilitate the rapid generation of 3D models from single images without the strict requirement of CUDA-enabled GPUs.

The deployment leverages Docker Swarm and GitHub Container Registry (GHCR) to ensure consistency and ease of distribution across local or cloud environments.

## Prerequisites

* Docker installed and configured.
* Docker Swarm initialized (`docker swarm init`).
* Access to an external Docker network named `claudao_network` (or modify `docker-compose.yml` to match your network setup).

## Installation and Deployment

1. Clone this repository to your host machine:
   ```bash
   git clone [https://github.com/Claudao01/triposr-docker-deployment.git](https://github.com/Claudao01/triposr-docker-deployment.git)
   cd triposr-docker-deployment
   ```

2. Configure the environment variables:
Copy the example file and modify the parameters if necessary.
   ```bash
   cp .env.example .env
   ```

3. Execute the deployment script:
Ensure the script has execution permissions before running it.
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. Access the interface:
Open your web browser and navigate to `http://localhost:7860`.

## Architecture Details

* **Base Image:** Python 3.10-slim.
* **Model Cache:** Hugging Face model weights are stored in a persistent Docker volume (`hf_cache`) to prevent redownloading across container restarts.
* **Resource Limits:** Memory usage is constrained within the `docker-compose.yml` file to prevent out-of-memory errors on the host machine. Default limits are set to 12GB.

## Continuous Integration

This project uses GitHub Actions to automatically build and push the Docker image to GHCR upon any changes merged into the `main` branch.