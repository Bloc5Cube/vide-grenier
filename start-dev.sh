#!/bin/bash

RESET_OPTION=false
for arg in "$@"
do
    if [ "$arg" == "--reset" ]; then
        RESET_OPTION=true
    fi
done

echo "Lancement de la version de développement..."

docker compose -p vg_dev -f docker-compose.yml up --build -d

echo "Attente de la base de données..."
docker compose -p vg_dev -f docker-compose.yml exec -T db sh -c 'while ! mariadb -u root -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do sleep 1; done'

if [ "$RESET_OPTION" = true ]; then
    echo "⚠️ OPTION RESET ACTIVÉE : Suppression et recréation de la base de données..."
    docker compose -p vg_dev -f docker-compose.yml exec -T db sh -c 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS \`$MARIADB_DATABASE\`; CREATE DATABASE \`$MARIADB_DATABASE\`;"'
fi

echo "Initialisation des tables..."
docker compose -p vg_dev -f docker-compose.yml exec -T db sh -c 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' < db/init.sql

echo "Vérification des données pour les seeders..."
COUNT=$(docker compose -p vg_dev -f docker-compose.yml exec -T db sh -c 'mariadb -NB -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE" -e "SELECT COUNT(*) FROM annonces;"')
if [ "$COUNT" = "0" ]; then
    echo "La table annonces est vide, exécution de seeder.sql..."
    docker compose -p vg_dev -f docker-compose.yml exec -T db sh -c 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' < db/seeder.sql
else
    echo "La table contient déjà $COUNT annonces, le seeder est ignoré."
fi

echo "Lancement terminé. Site accessible via http://localhost:8080"