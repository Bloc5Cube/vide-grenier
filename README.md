# Vide Grenier

[![PHP](https://img.shields.io/badge/PHP-777BB4?style=flat-square&logo=php&logoColor=white)](https://www.php.net)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docs.docker.com/compose)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)](https://mariadb.org)
[![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)](https://git-scm.com)

Plateforme web de gestion d'annonces pour un vide grenier. Application PHP + MariaDB containerisée avec Docker.

## Architecture

Le projet comprend deux environnements Docker:

- **Développement**: 2 conteneurs (PHP + MariaDB), code source exposé pour le développement
- **Production**: 2 conteneurs (PHP avec code embarqué + MariaDB persistante)

```mermaid
graph TB
    subgraph dev["Environnement Développement"]
        dev_src["📁 Code source<br/>./src"]
        dev_db["📁 Données<br/>./db_data_dev"]
        dev_php["🐳 PHP Container<br/>Port 8080"]
        dev_mariadb["🐳 MariaDB<br/>Port 3306"]

        dev_src -->|Volume| dev_php
        dev_db -->|Volume| dev_mariadb
        dev_php -->|Requêtes SQL| dev_mariadb
    end

    subgraph prod["Environnement Production"]
        prod_image["🖼️ Image Docker<br/>Code embarqué"]
        prod_data["📁 Données<br/>Volume persistant"]
        prod_php["🐳 PHP Container<br/>Port 80"]
        prod_mariadb["🐳 MariaDB"]

        prod_image -->|Build| prod_php
        prod_data -->|Volume| prod_mariadb
        prod_php -->|Requêtes SQL| prod_mariadb
    end

    dev_src -.->|Push main| prod_image
```

## Prérequis

- Docker et Docker Compose
- Git

## Démarrage - Environnement Développement

L'environnement de développement expose le code source pour la modification en direct et permet le rechargement automatique.

```bash
./start-dev.sh
```

L'application sera accessible à `http://localhost:8080`

**Services**:
- PHP: http://localhost:8080
- MariaDB: localhost:3306

## Démarrage - Environnement Production

L'environnement de production construit une image Docker intégrant le code et utilise des volumes persistants pour la base de données.

```bash
./start-prod.sh
```

L'application sera accessible à `http://localhost:80`

**Services**:
- PHP: http://localhost
- MariaDB: localhost:3306 (volume persistant)

## Arrêt des environnements

```bash
# Développement
docker-compose down -v

# Production
docker-compose -f docker-compose.prod.yml down -v
```

## Structure du projet

```
.
├── src/                      # Code source PHP
│   ├── index.php            # Application principale
│   └── style.css            # Feuille de style
├── db/                       # Scripts d'initialisation base de données
├── docker-compose.yml        # Configuration environnement développement
├── docker-compose.prod.yml   # Configuration environnement production
├── DockerFile               # Image PHP personnalisée
├── start-dev.sh            # Script de démarrage développement
└── start-prod.sh           # Script de démarrage production
```

## Workflow Git

Le projet utilise GitFlow:

- `main`: version stable en production
- `dev`: branche d'intégration des développements
- `feature/*`: branches de développement des fonctionnalités

Les changements sont intégrés via pull requests et vérifiés avant merge.

```mermaid
gitGraph
  commit id: "Initial commit"
  branch dev
  commit id: "Setup Docker"
  commit id: "Database schema"
  branch feature/annonces
  commit id: "Add listing feature"
  commit id: "Add styling"
  checkout dev
  merge feature/annonces
  commit id: "Merge feature"
  checkout main
  merge dev tag: "v1.0.0"
  commit id: "Production release"
```

## Déploiement d'une fonctionnalité

1. Créer une branche depuis `dev`
2. Développer et tester en environnement de développement
3. Pusher vers la branche et créer une PR vers `dev`
4. Après validation et merge, créer une PR `dev` → `main`
5. Redémarrer l'environnement de production pour déployer les changements
