# Docker Compose PHP

[![en](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](README.fr.md)

## Introduction

Ce projet fournit une configuration Docker Compose prête à l'emploi pour lancer PHP-FPM, le tout conteneurisé dans Docker. Il offre une base rationalisée pour le développement d'applications PHP en utilisant PHP-FPM comme moteur de traitement PHP. Le projet inclut un script de gestion complet (`docker-manager.sh`) qui simplifie les opérations Docker et fournit une interface intuitive pour gérer vos services conteneurisés.

## Versions des logiciels

Cette configuration Docker Compose inclut les versions de logiciels suivantes :

| Logiciel | Version |
|----------|---------|
| PHP-FPM  | 8.4     |

### Structure du Projet

```text
.
├── .github/
│   └── workflows/          # Workflows GitHub Actions
├── .env.example            # Variables d'environnement de développement
├── docker-compose.yml      # Configuration Docker Compose
├── docker-manager.sh       # Script de gestion pour les opérations Docker
├── LICENSE                 # Licence du projet
├── README.md               # Ce fichier
└── www/                    # Répertoire racine des fichiers PHP
```

### Prérequis

Avant d'utiliser ce Docker PHP, assurez-vous d'avoir les outils suivants installés :

- **Docker** : Plateforme de conteneurs (version 20.10 ou supérieure recommandée)
- **Docker Compose** : Applications Docker multi-conteneurs (version 2.0 ou supérieure)

## Utilisation

### Installation

1. Clonez ou téléchargez ce dépôt sur votre machine locale
2. Naviguez vers le répertoire du projet
3. Rendez le script de gestion exécutable :
   ```bash
   chmod +x docker-manager.sh
   ```
4. Vérifiez que Docker et Docker Compose sont en cours d'exécution

### Configuration

Pour commencer, créez un fichier `.env` en copiant le fichier `.env.example` comme point de départ :

```bash
cp .env.example .env
```

Configurez vos variables d'environnement dans le fichier approprié en fonction de votre cible de déploiement. Le script utilise automatiquement `.env` par défaut.

| Variable   | Description |
|------------|-------------|
| NAME       | Le nom du projet (utilisé dans les noms de conteneurs) |
| EXPOSE_PHP | Le port sur lequel PHP-FPM sera exposé |

### Exécution du Projet

Utilisez le script `docker-manager.sh` pour gérer vos conteneurs Docker. Le script fournit les commandes suivantes :

| Commande                                | Description                                                            |
|-----------------------------------------|------------------------------------------------------------------------|
| `./docker-manager.sh start`             | Démarrer tous les conteneurs Docker en mode détaché                    |
| `./docker-manager.sh stop`              | Arrêter tous les conteneurs Docker en cours d'exécution                |
| `./docker-manager.sh restart`           | Arrêter puis démarrer tous les conteneurs Docker                       |
| `./docker-manager.sh status`            | Afficher l'état actuel de tous les conteneurs                          |
| `./docker-manager.sh logs [CONTAINER]`  | Afficher les logs pour tous les conteneurs ou un conteneur spécifique  |
| `./docker-manager.sh connect [SERVICE]` | Connecter à un conteneur en cours d'exécution                          |
| `./docker-manager.sh env`               | Afficher les variables d'environnement actuelles                       |
| `./docker-manager.sh recreate`          | Récupérer les dernières images, reconstruire et recréer les conteneurs |
| `./docker-manager.sh prune`             | Supprimer les conteneurs arrêtés et les images/volumes inutilisés      |
| `./docker-manager.sh backup`            | Créer une sauvegarde de tous les volumes Docker                        |
| `./docker-manager.sh restore [FILE]`    | Restaurer les volumes Docker à partir du fichier de sauvegarde         |
| `./docker-manager.sh help`              | Afficher les informations d'aide avec toutes les commandes disponibles |
