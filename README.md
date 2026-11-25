# Multiplayer Game State Service
## CSCI 414/514 — Final Practical Project
**Group 05**

**Team Members:**
- Ganzorig Arvinbileg
- Zachariah Houck
- Shariquddin Mohammed

---

## 1. Project Overview

The Multiplayer Game State Service is a distributed application designed to simulate multiplayer game telemetry and manage player state information across isolated Docker network segments.

The application uses the OpenDota API as a public source of match data. The system processes match information, generates player-state updates, sends them through a FastAPI service, and stores the information in Redis.

The project demonstrates network infrastructure, distributed application development, network security, observability, performance testing, and automated failure recovery.

### Technologies Used

- Docker and Docker Compose
- Python
- FastAPI
- Uvicorn
- Redis
- Linux networking
- iptables / nftables
- OpenSSL
- tcpdump / Wireshark
- Python performance testing
- PowerShell automation

---

## 2. System Architecture

The application uses three isolated Docker network segments connected through a central router.

| Component | IP Address | Network |
|---|---|---|
| Central Router — Client Interface | 192.168.144.254 | Client Network |
| Game Client | 192.168.144.10 | 192.168.144.0/24 |
| Central Router — Service Interface | 192.168.145.254 | Service Network |
| API Server | 192.168.145.10 | 192.168.145.0/24 |
| Central Router — Database Interface | 192.168.146.254 | Data Network |
| NoSQL Database | 192.168.146.10 | 192.168.146.0/24 |

### Application Data Flow

1. The game client retrieves public match data from OpenDota.
2. The client generates player-state updates.
3. Requests travel through the central router.
4. The FastAPI server receives and processes the requests.
5. Redis stores the player-state information.
6. The API provides endpoints to update and retrieve player records.

The central router manages communication between the three isolated network segments.

---

## 3. Prerequisites

Before deploying the project, install:

- Docker Desktop
- Docker Compose
- Windows PowerShell or a compatible terminal
- Python 3
- Git

Make sure Docker Desktop is running before executing the deployment commands.

---

## 4. Project Files

The main project files include:

| File | Description |
|---|---|
| `docker-compose.yml` | Defines containers and isolated Docker networks |
| `main.py` | FastAPI application backend |
| `simulate.py` | OpenDota-based match simulation and state update script |
| `start_api.sh` | API server startup |
| `start_router.sh` | Router startup |
| `performance_test.py` | Measures API performance and request latency |
| `recovery.ps1` | PowerShell automation and API recovery script |
| `recovery.sh` | Shell recovery script |
| `Performance_Report.md` | Performance experiment results |
| `Recovery_Report.md` | Automation and recovery test results |
| `TestEvidence/` | Screenshots and testing evidence |

---

## 5. Deploying the Environment

### Step 1: Open the Project Directory

Open PowerShell or a terminal in the directory containing `docker-compose.yml`.

### Step 2: Start the Docker Environment

Run:

```bash
docker compose up -d
```

### Step 3: Verify Container Status

Run:

```bash
docker compose ps
```

The project should contain the following four main containers:

- `central_router`
- `game_client`
- `api_server`
- `nosql_db`

Make sure the containers are running before continuing.

---

## 6. Module A — Network Infrastructure and Topology

The project uses three isolated Docker networks connected through a central Linux router.

IP forwarding is enabled to allow communication between the network segments.

### Verify IP Forwarding

```bash
docker exec central_router sysctl net.ipv4.ip_forward
```

Expected result:

```text
net.ipv4.ip_forward = 1
```

### Verify Client Routing

```bash
docker exec game_client ip route
```

The default gateway should be:

```text
default via 192.168.144.254
```

### Verify Network Connectivity

Test communication with the API server:

```bash
docker exec game_client ping -c 3 192.168.145.10
```

Test communication with the database:

```bash
docker exec game_client ping -c 3 192.168.146.10
```

### Verify Routing Path

```bash
docker exec game_client traceroute -n 192.168.146.10
```

The first hop should show the central router interface:

```text
192.168.144.254
```

This confirms that traffic travels through the central router before reaching the database network.

---

## 7. Module B — Distributed Service and NoSQL Database

The application uses FastAPI as the API gateway and Redis as the NoSQL datastore.

### Start the API Server

If the API server is not already running, copy the application file:

```bash
docker cp main.py api_server:/app/main.py
```

Start Uvicorn:

```bash
docker exec -d api_server bash -c "cd /app && uvicorn main:app --host 0.0.0.0 --port 8000"
```

### Verify API Health

```bash
docker exec game_client python3 -c "import urllib.request; print(urllib.request.urlopen('http://192.168.145.10:8000/health').read().decode())"
```

Expected response:

```json
{"status":"healthy","database":"connected"}
```

### Run the Simulation

Copy the simulation script:

```bash
docker cp simulate.py game_client:/simulate.py
```

Run the simulation:

```bash
docker exec -it game_client python3 /simulate.py
```

The simulation processes match data and sends 1,050 player-state update events to the API.

### Verify Redis Storage

```bash
docker exec nosql_db redis-cli DBSIZE
```

The expected database size after the complete simulation is:

```text
(integer) 1050
```

---

## 8. Module C — Network Security

This module focuses on controlling communication between the isolated network segments.

The project uses firewall rules and access-control configurations to manage permitted and restricted traffic.

### Security Objectives

- Allow communication from the game client to the API server.
- Restrict direct access from the game client to the Redis database.
- Keep database access behind the API service.
- Use TLS certificates to secure client-to-API communication.

### Security Verification

The expected communication paths are:

| Source | Destination | Expected Access |
|---|---|---|
| Game Client | API Server | Allowed |
| API Server | Redis Database | Allowed |
| Game Client | Redis Database | Restricted |

Firewall and TLS configurations are included in the project implementation and supporting evidence.

---

## 9. Module D — Observability

This module focuses on monitoring network traffic and application activity.

The project uses packet-capture and logging tools to observe communication between the application components.

### Tools

- tcpdump
- Wireshark
- Uvicorn application logs
- Linux network utilities

### Observability Objectives

- Capture network traffic between application components.
- Inspect communication across network segments.
- Review API access logs.
- Observe application requests and responses.
- Support troubleshooting using packet captures and logs.

Relevant screenshots and evidence are stored in the `TestEvidence` directory.

---

## 10. Module E — Performance Experiments

Performance testing was performed using `performance_test.py`.

The script sends 1,050 sequential POST requests to the `/update_state` endpoint and measures request latency, execution time, throughput, and success rate.

### Baseline Test

The baseline test was performed under normal network conditions.

| Metric | Result |
|---|---:|
| Total Requests | 1,050 |
| Successful Requests | 1,050 |
| Failed Requests | 0 |
| Success Rate | 100% |
| Average Latency | 4.90 ms |
| Median Latency | 4.69 ms |
| P95 Latency | 6.04 ms |
| Total Execution Time | 5.15 seconds |
| Throughput | 203.75 requests/second |

### Network Impairment Test

Network impairment was applied to the game client's network interface using Linux `tc/netem`.

Configuration:

```bash
tc qdisc add dev eth0 root netem delay 100ms 10ms loss 1%
```

This configuration introduced:

- 100 ms network delay
- 10 ms jitter
- 1% packet loss

The same 1,050-request workload was executed again.

| Metric | Result |
|---|---:|
| Total Requests | 1,050 |
| Successful Requests | 1,050 |
| Failed Requests | 0 |
| Success Rate | 100% |
| Average Latency | 232.75 ms |
| Median Latency | 210.46 ms |
| P95 Latency | 224.87 ms |
| Total Execution Time | 244.40 seconds |
| Throughput | 4.30 requests/second |

### Results and Interpretation

The network impairment significantly increased request latency and execution time while reducing throughput.

All HTTP requests completed successfully because TCP retransmission handled packet loss.

The results demonstrate how network delay, jitter, and packet loss can affect application performance even when the service remains available.

After testing, the network impairment was removed:

```bash
docker exec game_client tc qdisc del dev eth0 root
```

---

## 11. Module F — Automation and Failure Recovery

This module demonstrates automated health checking, controlled failure simulation, and service recovery.

The project uses the PowerShell script `recovery.ps1`.

### Health Check

The script checks the API health endpoint:

```text
http://192.168.145.10:8000/health
```

If the API is healthy, the script reports that no recovery is needed.

### Controlled Failure

The Uvicorn API process was intentionally stopped while keeping the Docker container running.

Command:

```bash
docker exec api_server pkill -x uvicorn
```

A health check from the game client then returned a connection-refused error.

### Automated Recovery

Run the PowerShell recovery script from the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\recovery.ps1
```

The script performs these operations:

1. Checks API health.
2. Detects whether the API is unavailable.
3. Restarts the Uvicorn process.
4. Waits for the API to become available.
5. Performs another health check.
6. Reports whether recovery succeeded.

### Recovery Verification

The recovery test successfully restarted the API.

The final health response was:

```json
{"status":"healthy","database":"connected"}
```

The Uvicorn process was confirmed running after recovery.

This demonstrated that the API could recover from a process failure without restarting the entire Docker container.

---

## 12. Test Evidence

Screenshots and supporting evidence are stored in the `TestEvidence` directory.

Important evidence includes:

- `API_Error_Handling_404.png`
- `Client_API_Health_Check.png`
- `Client_Routing_Verification.png`
- `Network_Zone_Connectivity.png`
- `Performance_Baseline.png`
- `Performance_Network_Impairment.png`
- `Recovery_API_Failure.png`
- `Recovery_Automatic_Restart.png`

These screenshots document network connectivity, API functionality, performance measurements, and automated recovery.

---

## 13. Conclusion

The Multiplayer Game State Service demonstrates a distributed application operating across isolated Docker network segments.

The project combines network routing, API development, Redis storage, network security, observability, performance testing, and automated recovery.

Performance experiments showed that network impairment significantly increased latency and reduced throughput. The recovery experiment demonstrated that the API could be restored automatically after a controlled process failure.

Overall, the project provided practical experience in building, testing, monitoring, and recovering a distributed application.

---

## 14. Repository

**GitHub Repository:**

https://github.com/Shariq80/CSCI414-514_Final_Exam_Group_05

**Project:** CSCI 414/514 — Multiplayer Game State Service  
**Group:** 05  
**Semester:** Fall 2026
