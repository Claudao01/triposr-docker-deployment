#!/bin/bash
echo "Pulling the latest image from GitHub Container Registry..."
docker pull ghcr.io/claudao01/triposr-docker-deployment:main

echo "Deploying to Docker Swarm..."
docker stack deploy -c docker-compose.yml triposr_stack

echo "Deployment completed. Access http://localhost:7860 in a few seconds."