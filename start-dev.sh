#!/bin/bash

echo "Lancement de la version de développement..."

docker compose up --build -d

echo "Lancement terminé. Site accessible via http://localhost:8080"