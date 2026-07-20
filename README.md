# AAS-Level3
This repository contains the containerized **AAS Level 3** deployment stack.
The architecture ensures that all communication - whether to the AAS Web UI, the AAS Environment API, or the Identity Provider - is encrypted and authorized via Role-Based Access Control (RBAC).

## Architecture Overview
The stack is composed of 6 interconnected services running in a unified bridge network (`basyx-net`):

*   **Nginx Proxy (Port `3000`, `8081`, `9096`):** The single entry point. Handles SSL/TLS termination using local certificates and forwards requests to the respective services.
*   **AAS Web UI (Port `3000` via Proxy):** The front-end dashboard (Eclipse BaSyx GUI) to visualize and interact with your shells and submodels.
*   **AAS Environment (Port `8081` via Proxy):** The core API hosting the Asset Administration Shells, integrated with RBAC rules.
*   **Keycloak (Port `9096` via Proxy):** The Identity and Access Management (IAM) server handling client credentials and token issuance.
*   **MongoDB:** NoSQL database storing the AAS shell data and submodels.
*   **PostgreSQL:** Relational database powering Keycloak’s user and configuration schemas.

## Prerequisites
*   Docker/Podman compose
*   openssl

## Quick Start

### 1.Clone the repo:
```bash
git clone <github-repo-url>
cd <repo-folder-name>
```
### 2.Configure the Environment Variables
The stack relies on a .env file to securely inject credentials and network configurations into the containers

1. Copy the example environment file:
```bash
cp .env.example .env
```
2. Open `.env` and out the values.

#### Environment Configuration detail:
*   `MONGO_USER` & `MONGO_PASSWORD`: Root credentials for the MongoDB instance.
*   `KC_USER` & `KC_PASSWORD`: Admin credentials to log into the Keycloak Master Console.
*   `KC_DB_PASSWORD`: Password used internally by Keycloak to communicate with the PostgreSQL container.
*   `BASYX_SERVICE_SECRET`: The client secret generated in Keycloak for the `basyx-service` client (used for system-to-system auth).
*   `HOST_IP`: **Crucial.** This must be your machine's actual local network IP (e.g., `192.168.1.50`), **not** `localhost` or `127.0.0.1`.
    *   *Mac/Linux:* Run `ipconfig` or `ip a` to find it.
    *   *Windows:* Run `ipconfig` in Command Prompt.

### 3. Generate Local SSL Certificates
Because the proxy enforces HTTPS (`ssl` directive in `nginx.conf`), you must generate a self-signed certificate and private key before launching the services.

Run this single-line command from the project root directory. It creates the `./certs` folder if it doesn't exist and outputs the certificate files directly inside it:

```bash
mkdir -p certs && openssl req -x509 -newkey rsa:4096 -keyout certs/local.key -out certs/local.crt -sha256 -days 365 -nodes -subj "/CN=localhost"
```

### 4. Start the Stack
With your `.env` configured and certificates generated, spin up the entire multi-container application:

To run in the background (detached mode):
```bash
docker compose up -d
```

## Excel-to-AASX Data Extraction Branch

The `data_extract` branch adds the Excel-to-AASX generator under:

```text
excel-to-aasx/
```

Use it to generate AASX packages from supplier workbooks, then sync generated
packages into the runtime `aas/` folder:

```bash
cd excel-to-aasx
python3 -m venv .venv
. .venv/bin/activate
pip install -e .[dev]
make generate COMPANY=schunk
cd ..
./scripts/sync-generated-aasx.sh schunk
```

Detailed integration notes:

```text
docs/data-extraction-integration.md
```

## Accessing the Services
Once all containers show a healthy or started status in your terminal, the services are securely routed through the proxy:

| Service | Protocol / URL | Internal Port | External Proxy Port |
| :--- | :--- | :--- | :--- |
| **AAS Web UI** | `https://${HOST_IP}:3000` | `3000` | `3000` |
| **AAS Environment API** | `https://${HOST_IP}:8081` | `8081` | `8081` |
| **Keycloak IAM** | `https://${HOST_IP}:9096` | `8080` | `9096` |
