#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="/home/rmengert/docker-registry/image-storage/"
DEST_NODE="ka02" # Change this to the appropriate node hostname or IP
DEST_DIR="/home/rmengert/docker-registry/image-storage/"

# Use rsync to synchronize the directories
rsync -avz --delete $SOURCE_DIR ${DEST_NODE}:${DEST_DIR}