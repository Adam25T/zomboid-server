#!/bin/bash
set -e

echo "============================================"
echo "🧼 Wiping and Rebuilding Project Zomboid Server (Custom LGSM Docker Build)"
echo "============================================"
echo

# ---- CONFIG ----
CONTAINER_NAME="zomboid"
IMAGE_NAME="pz-lgsm-server"
VOLUME_PATH="/docker-volumes/project-zomboid"
USER_ID=1000
GROUP_ID=1000
COMPOSE_FILE="./docker-compose.yml"

# ---- STOP & REMOVE OLD CONTAINERS ----
echo "🧩 Stopping and removing existing containers..."
docker-compose down || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# ---- REMOVE OLD IMAGE ----
echo "🧱 Removing old local Docker image..."
docker rmi "$IMAGE_NAME" || true

# ---- DELETE OLD VOLUMES ----
echo "🧹 Deleting old server data and configs..."
sudo rm -rf "$VOLUME_PATH"

# ---- PRUNE UNUSED DOCKER DATA ----
echo "🗑️  Cleaning up unused Docker volumes..."
docker volume prune -f

# ---- RECREATE CLEAN DIRECTORY STRUCTURE ----
echo "📂 Recreating directories with correct ownership..."
sudo mkdir -p "$VOLUME_PATH/server-files"
sudo mkdir -p "$VOLUME_PATH/config-lgsm"
sudo chown -R $USER_ID:$GROUP_ID "$VOLUME_PATH"

# ---- VERIFY DOCKER FILES ----
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "⚠️ docker-compose.yml not found in current directory!"
  exit 1
fi

if [ ! -f "./Dockerfile" ]; then
  echo "⚠️ Dockerfile not found in current directory!"
  exit 1
fi

# ---- BUILD IMAGE (host network to fix DNS/timeouts) ----
echo "🐋 Building custom LGSM Project Zomboid image with host network..."
docker-compose build --no-cache --build-arg NETWORK_MODE=host

# ---- START CONTAINER ----
echo "🚀 Starting container with host network..."
docker-compose up -d --build --no-deps

echo "⏳ Waiting for LGSM to initialize and create config files..."
sleep 45

echo
echo "✅ Project Zomboid server rebuilt successfully!"
echo "Config directory: $VOLUME_PATH/server-files/Zomboid/Server/"
echo
echo "Use these commands to manage the server:"
echo "  docker exec -it -u linuxgsm $CONTAINER_NAME bash"
echo "  ./pzserver start"
echo "  ./pzserver details"
echo
echo "============================================"
echo "✨ Done!"
echo "============================================"