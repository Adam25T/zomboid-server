#!/bin/bash
set -e

# ----------------------
# Config
# ----------------------
CONTAINER_NAME="zomboid"
DATA_DIR="/docker-volumes/project-zomboid/data"

# Optional: wipe world saves only (keep configs)
WIPE_WORLD=false
if [[ "$1" == "--wipe-world" ]]; then
    WIPE_WORLD=true
fi

# ----------------------
# Stop container
# ----------------------
echo "🛑 Stopping container..."
docker-compose down

# ----------------------
# Wipe data if not preserving configs
# ----------------------
if [ "$WIPE_WORLD" = true ]; then
    echo "🗺️ Wiping world saves only..."
    sudo rm -rf "$DATA_DIR/serverfiles/Zomboid/Saves/Multiplayer"/*
    sudo rm -rf "$DATA_DIR/serverfiles/Zomboid/Saves/Survival"/*
else
    echo "🗑️ Deleting all server data..."
    sudo rm -rf "$DATA_DIR"/*
fi

# ----------------------
# Fix permissions
# ----------------------
echo "🔧 Fixing ownership and permissions..."
sudo mkdir -p "$DATA_DIR"
sudo chown -R 1000:1000 "$DATA_DIR"
sudo chmod -R u+rwX "$DATA_DIR"

# ----------------------
# Start container
# ----------------------
echo "🚀 Starting container..."
docker-compose up -d

# ----------------------
# Wait for LGSM to initialize
# ----------------------
echo "⏳ Waiting 60 seconds for LGSM to install and initialize..."
sleep 60

# ----------------------
# Status output
# ----------------------
echo "✅ Project Zomboid server is ready!"
echo
echo "📂 Data directory: $DATA_DIR"
echo
echo "Use the following commands to manage the server:"
echo "  docker exec -it --user linuxgsm $CONTAINER_NAME ./pzserver details"
echo "  docker exec -it --user linuxgsm $CONTAINER_NAME ./pzserver update"
echo "  docker exec -it --user linuxgsm $CONTAINER_NAME ./pzserver start"
echo
echo "⚠️ Use ./rebuild.sh --wipe-world to only wipe world saves without deleting configs."
