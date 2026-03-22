# 🚀 Inventory App

A modern, visually stunning inventory management web application built with **Flask** and a **glassmorphism** UI. Includes full **Docker** containerization and a **Jenkins CI/CD** pipeline.

> Perfect for DevOps academic presentations and learning modern web development patterns.

![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)
![Flask](https://img.shields.io/badge/Flask-3.0-green?logo=flask)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)

---

## ✨ Features

- 📦 **Product Management** — Add, view, and delete products
- 🎨 **Modern UI** — Glassmorphism design with floating cards and smooth animations
- 🚀 **Antigravity Effects** — Animated gradient orbs, bouncing icons, hover transitions
- 🔌 **REST API** — Clean JSON endpoints for all operations
- 🐳 **Dockerized** — One command to build and run
- ⚙️ **Jenkins Pipeline** — Automated testing, building, and deployment

---

## 📁 Project Structure

```
inventory-app/
├── app.py                 # Flask backend (API + routes)
├── test_app.py            # Pytest test suite
├── requirements.txt       # Python dependencies
├── Dockerfile             # Docker containerization
├── Jenkinsfile            # CI/CD pipeline definition
├── README.md              # This file
├── templates/
│   └── index.html         # Main HTML page
└── static/
    ├── style.css          # Glassmorphism + antigravity styles
    └── script.js          # Frontend logic (fetch API)
```

---

## 🏃 Run Locally

### Prerequisites

- Python 3.10+
- pip

### Steps

```bash
# 1. Clone or navigate to the project
cd inventory-app

# 2. Create a virtual environment
python -m venv venv

# 3. Activate it
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Run the app
python app.py
```

Open your browser at **http://localhost:5000** 🎉

---

## 🧪 Run Tests

```bash
# Make sure your virtual environment is activated
pytest test_app.py -v
```

---

## 🐳 Docker

### Build and Run

```bash
# Build the Docker image
docker build -t inventory-app .

# Run the container
docker run -d -p 5000:5000 --name inventory-app-container inventory-app

# Open http://localhost:5000
```

### Stop and Remove

```bash
docker stop inventory-app-container
docker rm inventory-app-container
```

---

## ⚙️ Jenkins CI/CD Pipeline

The `Jenkinsfile` now provides an automated, cross-platform pipeline (Linux + Windows agents).

### Pipeline Stages

| Stage                       | Description                                           |
| --------------------------- | ----------------------------------------------------- |
| **1. Checkout**             | Pulls the repository from SCM                         |
| **2. Install Dependencies** | Creates a Python venv and installs `requirements.txt` |
| **3. Run Tests**            | Runs `pytest` and publishes JUnit test results        |
| **4. Build Docker Image**   | Builds and tags `inventory-app` image                 |
| **5. Deploy (optional)**    | Deploys container only on `main` branch when enabled  |

### Jenkins Parameters

| Parameter  | Default | Description                                       |
| ---------- | ------- | ------------------------------------------------- |
| `DEPLOY`   | `false` | If true, deploys after successful build and tests |
| `APP_PORT` | `5000`  | Host port used when running the Docker container  |

### Setup Jenkins

1. Install Jenkins with the **Pipeline** and **Docker Pipeline** plugins.
2. Create a new **Pipeline** job (or **Multibranch Pipeline** recommended).
3. Connect the job to this repository and use `Jenkinsfile` from SCM.
4. Run build for CI (`DEPLOY=false`) or release (`DEPLOY=true` on `main`).

### What gets automated

- Test reports are published to Jenkins (`reports/pytest.xml`).
- Docker image is tagged with build number and `latest`.
- Deploy stage is gated to reduce accidental production changes.

---

## 🔌 API Endpoints

| Method   | Endpoint         | Description              |
| -------- | ---------------- | ------------------------ |
| `GET`    | `/`              | Serve the web UI         |
| `GET`    | `/products`      | List all products        |
| `POST`   | `/products`      | Add a new product        |
| `DELETE` | `/products/<id>` | Delete a product by ID   |
| `GET`    | `/health`        | Health check (for CI/CD) |

### Example: Add a Product

```bash
curl -X POST http://localhost:5000/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Keyboard", "category": "Electronics", "price": 79.99, "quantity": 50}'
```

---

## 🛠️ Tech Stack

| Layer     | Technology                  |
| --------- | --------------------------- |
| Backend   | Flask (Python)              |
| Frontend  | HTML + CSS + JavaScript     |
| Design    | Glassmorphism 
| Server    | Gunicorn                    |
| Container | Docker                      |
| CI/CD     | Jenkins                     |

---

## 📝 License

This project is for educational and academic purposes. Feel free to use and modify!
