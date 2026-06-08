#!/bin/bash

# Default deployment mode is swarm if not specified
MODE=${1:-swarm}

echo "Pulling the latest image from GitHub Container Registry..."
docker pull ghcr.io/claudao01/triposr-docker-deployment:main

if [ "$MODE" == "compose" ]; then
    echo "Deploying via Docker Compose (Standalone mode)..."
    docker compose up -d
    echo "Deployment completed. Access http://localhost:7860 in a few seconds."
else
    echo "Deploying to Docker Swarm (Cluster mode)..."
    docker stack deploy -c docker-swarm.yml triposr_stack
    echo "Deployment completed. Access http://localhost:7860 in a few seconds."
fi