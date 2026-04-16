#!/bin/bash

# Script to start both backend and frontend in new terminal tabs

# 1. Backend: Nitro Prisma Zod
gnome-terminal --tab --title="Conduit Backend" --working-directory="/home/rinne/projects/my-package/my-realworld/nitro-prisma-zod-realworld-example-app" -- bash -c "make run; exec bash"

# 2. Frontend: Elm RealWorld
gnome-terminal --tab --title="Conduit Frontend" --working-directory="/home/rinne/projects/my-package/elm-realworld" -- bash -c "npm run dev; exec bash"

echo "Servers started in new terminal tabs."
