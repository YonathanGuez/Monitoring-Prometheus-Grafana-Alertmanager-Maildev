# Deployment of Prometheus Grafana Alertmanager and MailDev for Windows/linux with Docker and Kubernetes

This project streamlines the deployment of Prometheus, Grafana, Alertmanager, and MailDev on both Windows and Linux operating systems. It's designed to enable Prometheus to gather data from Windows systems, creating an automation integration of four powerful open-source monitoring technologies.

![Alt text](./doc/grafana.png)

## Table of Contents

1. [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
	- [FAST START PROJECT](#FAST-START-PROJECT)
		- [Start with docker-compose](#Start-with-docker-compose)
		- [Start with Kubernetes](#Start-with-Kubernetes) 
2. [How to use Prometheus and Grafana](#usage)
    - [Installation and Configuration Prometheus](#installation-and-configuration-prometheus)
    - [Scraping the Data From Windows with Prometheus](#scraping-the-data-from-windows-with-prometheus)
    - [Test Prometheus Graph](#test-prometheus-graph)
    - [Display the Data in Grafana](#display-the-data-in-grafana)
3. [Real Dashboard with Windows_exporter](#real-dashboard-with-windows_exporter)
4. [Automate Deployment Prometheus and Dashboard Grafana](#automate-deployment-prometheus-and-dashboard-grafana)
        - [Linux](#linux)
        - [Windows](#windows)
5  [Test Alert Rules Prometheus](#test-alert-rules-prometheus)
6. [Stop And Remove Service windows_exporter](#stop-and-remove-service-windows_exporter)
7. [License](#license)

## Getting Started

### Prerequisites

- Windows 10/11
- Docker Desktop
- WSL

### FAST START PROJECT 

#### 1) Get data from Windows:
You need to [download windows exporter](https://github.com/prometheus-community/windows_exporter/releases/download/v0.24.0/windows_exporter-0.24.0-386.exe) and run :

```cmd
windows_exporter-0.24.0-386.exe --config.file=./windows_exporter/config-windowexporter.yml
```
 
My example is compatible only for get the data from windows.
If you want to get the data from linux you need to [download node_exporter](https://prometheus.io/download/#node_exporter) , run it and change the automation of prometheus and grafana !

#### 2) Start Deployment Docker-compose or Kubernetes:

##### * Start with docker-compose

Run:
create en .env and run docker-compose for build all environments ( you must build .env for config COMPUTER_IP)

```cmd
create_env.bat && docker-compose up
```

we will see multiple containers : prometheus / grafana / alertmanager / maildev / launchDashboard

##### * Start with Kubernetes

Before to run you need to launch windows_exporter and change in configmap-prom.yaml your IP :

```
....
- job_name: MyIP
        static_configs:
          - targets: ['YOUR_IP:9182']
....
```

```cmd
kubectl apply -f ./kubernetes/configmap-prom.yml
kubectl apply -f ./kubernetes/configmap-grafana.yml
kubectl apply -f ./kubernetes/configmap-alert.yml
kubectl apply -f ./kubernetes/deployment.yml
```

Check :

grafana: http://localhost:3000/

alertmanager: http://localhost:9093/

maildev: http://localhost:1080/

prometheus: http://localhost:9090/

Explanation:

We will see after 2 min that prometheus send an alert on alertmanager and alermanager transfer the alert on maildev (that is our test email)
laucherDashboard help us to create the dashboard of grafana for request the grafana API 
	
# How to use Prometheus and Grafana

## Installation and Configuration Prometheus

1. Run Docker Desktop on your machine.
2. If not already present, create the `C:\temp` folder.
3. Create `C:\temp\prometheus.yml` or copy the file from the repository. Add the following configuration:

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
    docker run -p 9090:9090 -v "C:\temp\prometheus.yml":/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus
    ```
6. Open Your Chrome and check :
	```
	http://localhost:9090
	```
	You will see Prometheus site on your local,  Prometheus exports now data of itself
	you can check it with **http://localhost:9090/metrics** you will see all data it s scrape from itself
	

## Scraping the Data From Windows with Prometheus:

### 1. Download and install the module windows_exporter :

[List of Release](https://github.com/prometheus-community/windows_exporter/releases)

1. You have a lot of choise , I used windows_exporter-0.24.0-386.exe

	If you use my repo put the exe in my repository

2. create config-windowexporter.yml or use the file in my repo :
```yml
collectors:
  enabled: cpu,cs,logical_disk,net,os,service,textfile
collector:
  service:
    services-where: Name='windows_exporter'
log:
  level: warn
scrape:
  timeout-margin: 0.5
telemetry:
  path: /metrics
  max-requests: 5
web:
  listen-address: ":9182"
```

3. Run windows_exporter like this :
```cmd
windows_exporter-0.24.0-386.exe --config.file=config-windowexporter.yml
``` 

4. Check the metric in : **http://localhost:9182/metrics**

5. Now Create a Service for run that automaticly 

You must open your CMD with mode administrator 

```cmd
sc create windows_exporter binPath= "C:\path\to\windows_exporter-0.24.0-386.exe --config.file=C:\path\to\config-windowexporter.yml"
```

6. Check if your windows_exporter run , go to Search Windows > Services ,open it and check the Service name: windows_exporter

### 2. Configure Prometheus for scrape the data from windows:

1. first you need to stop you Prometheus server :

- stop the server
- remove volume:

```cmd
docker volume rm -f  prometheus-data
```

if you not succed to remove maybe you need to remove all containes build ( check docker ps -a )

2. Reconfigure the file prometheus.yml :
change the job_name by th name of your computer and change IP_WINDOWS by your IP and PORT_WINDOWS_EXPORTER by 9182 that we use for windows_exporter

    ```yaml
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: NAME_COMPUTER
        static_configs:
          - targets: ['IP_WINDOWS:PORT_WINDOWS_EXPORTER']
    ```
	
3. Create a new volume and run the Server Prometheus 

	```cmd
	docker volume create prometheus-data
	docker run -p 9090:9090 -v "C:\temp\prometheus.yml":/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus
	```
	
4. check if you have the connection with your windows_exporter:
go to your prometheus > target or put this URL **http://localhost:9090/targets?search=**
![Alt text](./doc/target.png)


if you see your NAME_COMPUTER click on "show more" and check if status is Up with your IP 

### 3. Test Prometheus Graph:

**http://localhost:9090/graph**

1. Add a data that you can see on your metric windows_exporter to the expression bar :

example :
* http://localhost:9182/metrics
I have this data 
```
....
process_cpu_seconds_total 1.09375
process_max_fds 1.6777216e+07
....

```
go to graph Prometheus and add process_cpu_seconds_total in the bar 

* Now i want something more precise:
I want my total CPU use 
```
sum(rate(process_cpu_seconds_total[1m])) / count(process_cpu_seconds_total) * 100
```

## Display the Data in Grafana:

### 1 Download install and discover Grafana :

a. Create Volume and first run Grafana :
```cmd
docker volume create grafana-storage
docker run -d -p 3000:3000 --name=grafana --volume grafana-storage:/var/lib/grafana grafana/grafana
```

b. First steps Dashboard :
go to the URL : **http://localhost:3000/**
put user : admin
    password : admin 
	
you can reset the password you can add the same password if you want

c. Go to "Connection" > "Data Sources" > "Add data source."

d. Choose "Prometheus" from the list of available data sources.

e. In the "HTTP" section, set the URL to the Prometheus endpoint:

	***************************************************
	* thit Step will be not working i will explaine   *
	***************************************************
because you need to give him the IP of your docker prometheus

URL: http://localhost:9090

Go Down and Click on "Save & Test" to ensure that Grafana can connect to Prometheus successfully.
you will get Connection refuse 

	**************
	*Solution 1: *
	**************
Get the IP of docker prometheus
```
docker ps 
# check the id of your container prometheus or get the name of your container
docker inspect -f '{{.NetworkSettings.IPAddress}}' ID_OR_NAME_CONTAINER_PROMETHEUS
```
you will get the IP 

change the URL: http://IP_CONTAINER_PROMETHEUS:9090

	
	**************
	*Solution 2: *
	**************
Put Grafana and prometheus in the same network :
1. Stop prometheus and grafana:

```cmd
docker ps
docker stop ID_PROMETHEUS
docker stop ID_GRAFANA
```

2. Create network

```cmd
docker network create monitoring
```

3. Run Prometheus like this :
```cmd
docker run -p 9090:9090 --name prometheus --network monitoring -v "C:\temp\prometheus.yml":/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus
```

4. Run Grafana like this :

```cmd
docker run -d -p 3000:3000 --network monitoring --name=grafana --volume grafana-storage:/var/lib/grafana grafana/grafana
```

5. check the network:

```cmd
docker inspect monitoring
```

You will see 2 container related name: grafana and prometheus

so now is more simple for use we only need to put in 
URL : http://prometheus:9090/

Go Down and Click on "Save & Test" to ensure that Grafana can connect to Prometheus successfully.

### USE API Grafana:

#### Create an API Token and a Dashboard:

For all this steps if you are on windows like me i advice to use cmd of MINGW64 (if you have git you only need to open git bash terminal )

1. Create Organization:

```
curl -X POST -H "Content-Type: application/json" -d '{"name":"apiorg"}' http://admin:admin@localhost:3000/api/orgs

```

result : {"message":"Organization created","orgId":2}


2.Switch the org context for the Admin user to the new org:

```cmd
#curl -X POST http://admin:admin@localhost:3000/api/user/using/<id of new org>
curl -X POST http://admin:admin@localhost:3000/api/user/using/2
``` 

3. Create a Service Account:

```cmd
curl -X POST -H "Content-Type: application/json" -d '{"name":"test", "role": "Admin"}' http://admin:admin@localhost:3000/api/serviceaccounts
```
result: {"id":3,"name":"test","login":"sa-test","orgId":2,"isDisabled":false,"role":"Admin","tokens":0,"avatarUrl":""}

4. Create a Service Account token:

```cmd
#curl -X POST -H "Content-Type: application/json" -d '{"name":"test-token"}' http://admin:admin@localhost:3000/api/serviceaccounts/<service account id>/tokens
curl -X POST -H "Content-Type: application/json" -d '{"name":"test-token"}' http://admin:admin@localhost:3000/api/serviceaccounts/3/tokens

```
result : {"id":2,"name":"test-token","key":"glsa_b60AauSVVN35pMEE9bAd87Bzad8iMFaz_96041486"}

5. Create a Database Source in Grafana:

```cmd
DATASOURCE=$(cat datasource-prometheus.json)
curl -X POST --insecure -H "Authorization: Bearer KEY_TOKEN_API" -H "Content-Type: application/json" -d "$DATASOURCE" http://localhost:3000/api/datasources
```

6. Create the first Dashboard :

Don't forget to change the KEY_TOKEN_API

```cmd
curl -X POST --insecure -H "Authorization: Bearer KEY_TOKEN_API" -H "Content-Type: application/json" -d '{
  "dashboard": {
    "id": null,
    "title": "Production Overview",
    "tags": [ "templated" ],
    "timezone": "browser",
    "rows": [
      {
      }
    ],
    "schemaVersion": 6,
    "version": 0
  },
  "overwrite": false
}' http://localhost:3000/api/dashboards/db
```

Now you can check if you have a Dashboard in your Grafana:

```
home > Administration > organization >apiorg
					  > service account > test > tokens > test-token
	 > Dashboard > Production Overview
			  
```

## Real Dashboard with Windows_exporter :

( with the help of the work of [starsliao](https://github.com/starsliao/Prometheus) )

I build [My Dashboard](./grafana/dashboardwindows.json)


## Automate Deployment Prometheus and Dashboard Grafana

### Linux:

1) Create file prometheus-IP.yml :[authomation_config_prometheus_yml.sh](./scripts/linux/authomation_config_prometheus_yml.sh) :

```cmd
./authomation_config_prometheus_yml.sh
```

2) [create-dashboard-api.sh](./scripts/linux/create-dashboard-api.sh) :

```cmd
./create-dashboard-api.sh dashboardwindows.json
```

### Windows :

1) Create file prometheus-IP.yml :[authomation_config_prometheus_yml.ps1](./scripts/windows/authomation_config_prometheus_yml.ps1) :

```cmd
powershell -File authomation_config_prometheus_yml.ps1
```


2) [create-dashboard-api.ps1](./scripts/windows/create-dashboard-api.ps1) :

```cmd
.\create-dashboard-api.ps1 dashboardwindows.json
```

## Test Alert Rules Prometheus:

![Alt text](./doc/statusRuleCPU.png)

Create an Alert CPU rules.yml that UP after 20% used:
```yml
groups:
- name: cpu_alerts
  rules:
  - alert: HighCpuUsage
    expr: (100 * sum(rate(windows_cpu_time_total{mode=~"user|privileged"}[5m])) / 300)*100 > 20
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High CPU Usage Detected"
      description: "CPU usage is above 20% for at least 2 minutes."
```

we will change our prometheus.yml :

```yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

rule_files:
  - 'rules.yml'
  
scrape_configs:
  - job_name: MyIP
    static_configs:
      - targets: ['IPAddress:9182']
```

now our rule is configurate i need to add my file rules.yml in my docker :

```
docker run -p 9090:9090 --name prometheus --network monitoring -v "C:\temp\rules.yml":/etc/prometheus/rules.yml -v "C:\temp\prometheus.yml":/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus
```

My alert is ready we can wait 2 minutes and see it :
![Alt text](./doc/alertCPU.png)
 

## Stop And Remove Service windows_exporter:

Use CMD in Administrator:
1. stop :

```cmd
sc stop windows_exporter
```

2. Remove Service :
```cmd
sc delete windows_exporter
```

## TIPS

Check prometheus YAML :
go in the docker container prometheus:

```cmd
promtool check config prometheus.yml
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
