<!-- dex:docker-compose -->
---
name: docker-compose
description: Docker Compose configuration and multi-container orchestration. Use when working with docker-compose.yaml files or multi-container setups.
---

# Docker Compose

You know Docker Compose - the tool for defining and running multi-container Docker applications using YAML files.

## When to Use This Skill

Use when working with:
- `docker-compose.yaml` or `docker-compose.yml` files
- Multi-container applications
- Local development environments with Docker

## Basic Structure

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html

  api:
    build: ./api
    environment:
      DATABASE_URL: postgres://db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}

volumes:
  db-data:

networks:
  default:
    driver: bridge
```

## Common Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f service-name

# Execute commands in containers
docker-compose exec service-name sh

# List containers
docker-compose ps

# Stop and remove
docker-compose down

# Rebuild
docker-compose build
docker-compose up -d --build
```

## MCP Tasks Available

This package includes MCP tasks:
- List containers
- View logs
- Execute commands in containers
- Restart/rebuild services

<!-- /dex:docker-compose -->
