#!/bin/bash

# Name of the Docker container to check
CONTAINER_NAME="zarf-registry"

# Check if the Docker container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  # Container is running, exit with status 0
  exit 0
else
  # Container is not running, exit with status 1
  exit 1
fi