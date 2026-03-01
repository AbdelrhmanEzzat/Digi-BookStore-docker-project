#!/bin/bash
set -e

# Load .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "🐳 Building image..."
docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} .
docker tag ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest

echo "🚀 Pushing to Docker Hub..."
docker login
docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest

echo "✅ Done! Image available at:"
echo "   docker pull ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
