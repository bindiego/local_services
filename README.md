

# Local Services

This repository contains a collection of scripts and configurations for running various services locally, primarily using Docker.

## Overview

This project provides a convenient way to set up and manage a variety of services for development and testing purposes. Each service is contained within its own directory and can be started and configured independently.

## Services

Here is a list of the services available in this repository:

*   **cAdvisor:** Monitor your Docker containers on the host at `localhost:12080`.
*   **ClickHouse:** A fast, open-source column-oriented database management system.
*   **code-server:** Run VS Code on a remote server.
*   **cpuburner:** A simple CPU stress-testing tool.
*   **CRM:**
    *   **SugarCRM:** A popular open-source customer relationship management (CRM) system.
    *   **SuiteCRM:** An open-source alternative to SugarCRM.
*   **Docker:** Scripts for managing Docker.
*   **Druid:** A high-performance, real-time analytics database.
*   **Elastic Stack:**
    *   **Elasticsearch:** A distributed, RESTful search and analytics engine.
    *   **Kibana:** A visualization and exploration tool for Elasticsearch.
    *   **Beats:** A platform for single-purpose data shippers.
*   **Grafana:** An open-source platform for monitoring and observability.
*   **HDFS:** The Hadoop Distributed File System.
*   **Hive:** A data warehouse infrastructure built on top of Hadoop.
*   **Hue:** A web-based interactive query editor for Hadoop.
*   **Impala:** A massively parallel processing (MPP) SQL query engine for data stored in a computer cluster running Apache Hadoop.
*   **Java:** Scripts for installing Java.
*   **Jenkins:** An open-source automation server.
*   **Kubernetes:** Scripts and configurations for working with Kubernetes.
*   **Kudu:** A columnar storage manager for the Hadoop ecosystem.
*   **Locust:** An easy-to-use, distributed, user load testing tool.
*   **Minio:** A high-performance, distributed object storage system.
*   **MongoDB:** A cross-platform document-oriented database program.
*   **MySQL:** An open-source relational database management system.
*   **netdata:** A distributed, real-time, performance and health monitoring for systems and applications.
*   **Nexus:** A repository manager.
*   **nginx:** A web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache.
*   **PHP:** A popular general-purpose scripting language that is especially suited to web development.
*   **Portainer:** A lightweight management UI which allows you to easily manage your different Docker environments.
*   **PostgreSQL:** A powerful, open-source object-relational database system.
*   **Prometheus:** An open-source systems monitoring and alerting toolkit.
*   **pytcp:** A simple TCP server and client for testing connection establishment time.
*   **Redis:** An in-memory data structure store, used as a database, cache and message broker.
*   **RStudio:** An integrated development environment for R.
*   **Selenium:** A portable framework for testing web applications.
*   **Shadowsocks:** A free and open-source encrypted proxy project.
*   **SonarQube:** An open-source platform for continuous inspection of code quality.
*   **Superset:** A modern, enterprise-ready business intelligence web application.
*   **tcp-syn-scan:** A simple TCP SYN port scanner.

## Getting Started

To get started with a specific service, navigate to its directory and follow the instructions in the corresponding `README.md` file. Most services can be started with a simple `make` or `docker-compose up` command.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
