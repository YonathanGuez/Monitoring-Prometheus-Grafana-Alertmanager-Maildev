# Prometheus and Grafana Integration on Windows

This project facilitates the seamless integration of Prometheus and Grafana on the Windows operating system. Prometheus, an open-source monitoring and alerting toolkit, and Grafana, a widely used analytics and monitoring platform, combine to create a powerful monitoring solution for Windows-based environments.

## Features

- **Prometheus Monitoring:** Set up Prometheus to collect and store time-series data from Windows machines, enabling in-depth monitoring of various metrics such as system performance, resource utilization, and application-specific statistics.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Getting Started

### Prerequisites

- Windows 10 Home
- Docker Desktop

### Installation

1. Run Docker Desktop on your machine.
2. If not already present, create the `C:\temp` folder.
3. Create `C:\temp\prometheus-firstrun.yml` or copy the file from the repository. Add the following configuration:

    ```yaml
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets: ['localhost:9090']
    ```
    
4. Create persistent volume for your data
	```cmd
	docker volume create prometheus-data
	```
5. Open a command prompt (CMD) and execute the following commands:

    ```cmd
    docker pull prom/prometheus
    docker run -p 9090:9090 -v "C:\temp\prometheus-firstrun.yml":/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus
    ```
6. Open Your Chrome and check :
	```
	http://localhost:9090
	```
	You will see Prometheus site on your local 
	
# Usage


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
