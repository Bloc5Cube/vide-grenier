#!/bin/bash

echo "Lancement de la version de production..."

git checkout main
git pull origin main

docker compose -f docker-compose.prod.yml up --build -d

echo "Lancement terminé avec succès !"