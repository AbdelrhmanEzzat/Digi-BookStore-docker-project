# 📚 Lab 6 — BookStore API

A production-style Docker stack built as a demo for the **Docker Advanced Course**.

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.0-000000?style=flat&logo=flask&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?style=flat&logo=nginx&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?style=flat&logo=redis&logoColor=white)

-----

## 🏗️ Architecture

```
Browser
   │
   │  HTTPS :443
   ▼
┌─────────────────────────────┐
│          NGINX              │  ← SSL Termination
│   Load Balancer + Rate Limit│    Static Files
│         + Gzip              │    HTTP→HTTPS Redirect
└──────────┬──────────────────┘
           │ least_conn
     ┌─────┴─────┐
     │           │
     ▼           ▼
┌─────────┐ ┌─────────┐
│ flask1  │ │ flask2  │  ← Gunicorn 2 workers each
│ :8000   │ │ :8000   │    Non-root user
└────┬────┘ └────┬────┘    HEALTHCHECK
     └─────┬─────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
┌──────────┐ ┌──────────┐
│PostgreSQL│ │  Redis   │  ← Persistent Volumes
│  :5432   │ │  :6379   │    Health Checks
└──────────┘ └──────────┘
```

-----

## ✨ Features

|Feature                   |Details                                                |
|--------------------------|-------------------------------------------------------|
|**Multi-stage Dockerfile**|Builder + Runtime — image ~120MB instead of ~1GB       |
|**Non-root user**         |`appuser` — security best practice                     |
|**Health Checks**         |All services — `depends_on: condition: service_healthy`|
|**Redis Cache**           |`books:all` cached for 60 seconds                      |
|**SSL/HTTPS**             |Self-signed certificate via OpenSSL                    |
|**Load Balancing**        |Nginx `least_conn` across 2 Flask workers              |
|**Rate Limiting**         |20 req/s per IP on `/api/`                             |
|**Resource Limits**       |Flask: 0.5 CPU / 256MB — Postgres: 512MB               |
|**Compose Profiles**      |pgAdmin available with `--profile tools`               |

-----

## 🚀 Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/lab6-bookstore.git
cd lab6-bookstore
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env and set your values
```

### 3. Generate SSL certificate

```bash
cd ssl && bash generate_ssl.sh && cd ..
```

### 4. Build and run

```bash
docker compose up -d --build
```

### 5. Open in browser

```
https://localhost
```

> Click **Advanced → Proceed to localhost** for the self-signed certificate warning.

-----

## 🔌 API Endpoints

|Method|Endpoint     |Description                      |
|------|-------------|---------------------------------|
|`GET` |`/`          |Web UI                           |
|`GET` |`/api/health`|Health check — DB + Redis status |
|`GET` |`/api/books` |Get all books (Redis cache first)|
|`POST`|`/api/books` |Add a new book                   |

### Examples

```bash
# Health check
curl -k https://localhost/api/health

# Get all books
curl -k https://localhost/api/books

# Add a book
curl -k -X POST https://localhost/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Clean Code","author":"Robert C. Martin"}'
```

-----

## ⚙️ Services

|Service   |Image             |Port           |Notes             |
|----------|------------------|---------------|------------------|
|`nginx`   |nginx:alpine      |80, 443        |Entry point       |
|`flask1`  |build: .          |8000 (internal)|Worker 1          |
|`flask2`  |build: .          |8000 (internal)|Worker 2          |
|`postgres`|postgres:16-alpine|5432 (internal)|Main DB           |
|`redis`   |redis:7-alpine    |6379 (internal)|Cache             |
|`pgadmin` |dpage/pgadmin4    |5050           |Optional (profile)|

### Run with pgAdmin

```bash
docker compose --profile tools up -d
# Open: http://localhost:5050
# Email: admin@lab.local  Password: admin123
```

-----

## 📁 Project Structure

```
lab6-bookstore/
├── Dockerfile              # Multi-stage build
├── docker-compose.yml      # 6 services
├── flask_app.py            # BookStore REST API
├── requirements.txt        # Python dependencies
├── init.sql                # DB schema + sample data
├── .env                    # Secrets (not in git!)
├── .env.example            # Template for team
├── .dockerignore           # Keep secrets out of image
├── push.sh                 # Docker Hub push script
├── conf/
│   └── nginx.conf          # Nginx configuration
├── static/
│   └── style.css           # Frontend CSS
└── ssl/
    └── generate_ssl.sh     # Self-signed cert generator
```

-----

## 🔧 Useful Commands

```bash
# Check all services status
docker compose ps

# Watch logs live
docker compose logs -f

# Check specific service
docker compose logs flask1
docker compose logs postgres

# Test load balancing (watch worker change)
curl -k https://localhost/api/health
curl -k https://localhost/api/health

# Stop everything
docker compose down

# Stop and remove volumes (deletes DB data)
docker compose down -v
```

-----

## 🐛 Troubleshooting

|Problem                            |Solution                                                |
|-----------------------------------|--------------------------------------------------------|
|`nginx: host not found flask1`     |Flask not ready yet — wait 30s and retry                |
|`cannot load certificate`          |Run `cd ssl && bash generate_ssl.sh` first              |
|`502 Bad Gateway`                  |`docker compose logs flask1` to check Flask             |
|`connection refused postgres`      |Check `depends_on: condition: service_healthy`          |
|Image not updated after code change|Use `docker compose up -d --build`                      |
|Want fresh start                   |`docker compose down -v && docker compose up -d --build`|

-----

## ☁️ Push to Docker Hub

```bash
# Edit .env first — set DOCKER_HUB_USER and IMAGE_NAME
bash push.sh
```

Image will be available at:

```
docker pull YOUR_USERNAME/bookstore:v1.0
```

-----

## 📸 Screenshots

> Add your screenshots here after running the project.

|App UI                     |Services Status          |
|---------------------------|-------------------------|
|![app](screenshots/app.png)|![ps](screenshots/ps.png)|

-----

## 📖 Course

This lab is part of the **Docker Advanced Course** covering:

- Multi-stage Dockerfiles
- Docker Compose advanced features
- Production patterns (health checks, resource limits, logging)
- Nginx reverse proxy + SSL
- Redis caching
- Docker Hub deployment