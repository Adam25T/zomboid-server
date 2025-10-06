#!/bin/bash
set -e

CONTAINER_NAME="zomboid"
IMAGE_NAME="pz-lgsm-server"
VOLUME_PATH="/docker-volumes/project-zomboid/server-files"

echo "============================================"
echo "🧼 Wiping and Rebuilding Project Zomboid Server"
echo "============================================"

# Stop & remove old container
docker-compose down || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Remove old image
docker rmi "$IMAGE_NAME" || true

# Optional world wipe
if [ "$1" == "--wipe-world" ]; then
  echo "🗺️ Wiping world save files..."
  sudo rm -rf "$VOLUME_PATH/Zomboid/Saves/Multiplayer"/*
  sudo rm -rf "$VOLUME_PATH/Zomboid/Saves/Survival"/*
  echo "✅ World save data wiped, configs retained."
fi

# Remove old server files
echo "🧹 Deleting old server files..."
sudo mkdir -p "$VOLUME_PATH"
sudo chown -R 1000:1000 "$VOLUME_PATH"

# Build image
echo "🐋 Building Docker image..."
docker-compose build --no-cache

# Start container
echo "🚀 Starting container..."
docker-compose up -d

# Wait for container to initialize
sleep 10

# Install Project Zomboid server inside container
echo "🛠️ Installing Project Zomboid server inside container..."
docker exec -u linuxgsm -it $CONTAINER_NAME bash -c "
  ./linuxgsm.sh pzserver
"

# Update LGSM inside container
echo "🔄 Updating LGSM..."
docker exec -u linuxgsm -it $CONTAINER_NAME bash -c "
  ./pzserver update-lgsm
"

# Start Project Zomboid server
echo "▶️ Starting Project Zomboid server..."
docker exec -u linuxgsm -it $CONTAINER_NAME bash -c "
  ./pzserver start
"

echo "✅ Project Zomboid server is fully running!"
echo
echo "Use inside container:"
echo "  docker exec -it -u linuxgsm $CONTAINER_NAME bash"
echo "  ./pzserver details"
echo "  ./pzserver stop"
echo
echo "============================================"
echo "✨ Done!"
echo "============================================"
