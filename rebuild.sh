#!/bin/bash
set -e

echo "============================================"
echo "🧼 Wiping and Rebuilding Project Zomboid Server"
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
echo "🗑️ Cleaning up unused Docker volumes..."
docker volume prune -f

# ---- RECREATE CLEAN DIRECTORY STRUCTURE ----
echo "📂 Recreating directories..."
sudo mkdir -p "$VOLUME_PATH/server-files"
sudo mkdir -p "$VOLUME_PATH/config-lgsm"

# ---- FIX OWNERSHIP ON HOST VOLUMES ----
echo "🔑 Setting correct ownership for linuxgsm user..."
sudo chown -R $USER_ID:$GROUP_ID "$VOLUME_PATH"

# ---- VERIFY DOCKER FILES ----
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "⚠️ docker-compose.yml not found!"
  exit 1
fi
if [ ! -f "./Dockerfile" ]; then
  echo "⚠️ Dockerfile not found!"
  exit 1
fi

# ---- BUILD IMAGE ----
echo "🐋 Building custom LGSM Project Zomboid image..."
docker-compose build --no-cache

# ---- START CONTAINER ----
echo "🚀 Starting container..."
docker-compose up -d

# ---- WAIT FOR INITIALIZATION ----
echo "⏳ Waiting 10s for container to initialize..."
sleep 10

# ---- INSTALL LGSM PZServer INSIDE CONTAINER ----
echo "🛠️ Installing Project Zomboid server inside container..."
docker exec -u linuxgsm -it $CONTAINER_NAME bash -c "
  # Ensure lgsm/data exists inside container (not on host-mounted config)
  mkdir -p /home/linuxgsm/lgsm/data
  ./linuxgsm.sh pzserver
"

echo "✅ Rebuild complete!"
echo
echo "Use inside container:"
echo "  docker exec -it -u linuxgsm $CONTAINER_NAME bash"
echo "  ./pzserver update-lgsm"
echo "  ./pzserver details"

# ---- OPTIONAL: WORLD WIPE MODE ----
if [ "$1" == "--wipe-world" ]; then
  echo "🗺️ Wiping world save files only..."
  sudo rm -rf "$VOLUME_PATH/server-files/Zomboid/Saves/Multiplayer"/*
  sudo rm -rf "$VOLUME_PATH/server-files/Zomboid/Saves/Survival"/*
  echo "✅ World save data wiped, configs retained."
fi
