#!/bin/env bash
source ./.env

echo "Building jenkins..."
docker build -t "${DOCKER_REGISTRY}"/jenkins-server:latest .

echo "Pushing jenkins..."
cat .token | docker login $DOCKER_REGISTRY -u $DOCKER_REGISTRY_USER --password-stdin
docker push ${DOCKER_REGISTRY}/jenkins-server:latest
