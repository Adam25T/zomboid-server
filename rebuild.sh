#!/bin/bash
set -e

echo "🧼 Stopping container..."
docker-compose down

echo "🗑️ Deleting old server data..."
sudo rm -rf /docker-volumes/project-zomboid/data/*

echo "🚀 Starting fresh container..."
docker-compose up -d

echo "⏳ Waiting for Project Zomboid server to install..."
sleep 60

echo "✅ Project Zomboid server rebuilt successfully!"
echo "Use the following commands to manage the server:"
echo "  docker exec -it --user linuxgsm zomboid ./pzserver details"
echo "  docker exec -it --user linuxgsm zomboid ./pzserver update"
echo "  docker exec -it --user linuxgsm zomboid ./pzserver start"
