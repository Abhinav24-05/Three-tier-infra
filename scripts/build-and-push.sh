#!/usr/bin/env bash
set -euo pipefail

REPO_URI="$1" # e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/three-tier-api
TAG="${2:-latest}"

echo "Building image ${REPO_URI}:${TAG}..."
docker build -t "${REPO_URI}:${TAG}" services/api

echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION:-us-east-1} | docker login --username AWS --password-stdin "$(echo $REPO_URI | cut -d'/' -f1)"

echo "Pushing image..."
docker push "${REPO_URI}:${TAG}"

echo "Done."
