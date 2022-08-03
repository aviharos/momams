# Manufacturing OEE and MES Alert Management System (MOMAMS)
[![License: MIT](https://img.shields.io/github/license/ramp-eu/TTE.project1.svg)](https://opensource.org/licenses/MIT)

## Purpose

MOMAMS provides a system for
- logging manufacturing systems,
- calculating OEE values,
- OEE visualisation and
- sending alerts for operators about upcoming tasks.

## Overview
The system was developed as a part of a  [DIH²](http://dih-squared.eu/) project.
Developed by the Robo4Toys (R4T) TTE: [Robo-Tech Service Ltd.](https://robo-tech.hu/en/), [Artrade Ltd.](https://shop.rubik.hu/en/).

The system is capable of handling manufacturing systems that
- match the criteria of the [Job-shop scheduling problem](https://en.wikipedia.org/wiki/Job-shop_scheduling),
- is capable of constantly updating the objects in the Orion context broker.

## Architecture and modules
The overall architecture is shown below: 
![MOMAMS architecture and modules](img/R4T.drawio.png)

The software components can be separated into 3 groups: 
- [Fiware](https://github.com/Fiware/tutorials.Getting-Started) software components,
- 3rd party software,
- Custom TTE software.

The [R4T OEE microservice](https://github.com/aviharos/oee) and the [R4T IoT agent for Siemens S7-15xx PLCs](https://github.com/aviharos/iotagent-http) are microsercices that can be used integrated into the MOMAMS system or without integration.

The software components run in [docker](https://www.docker.com/) containers in a project as follows.

The [Orion Context Broker](https://fiware-orion.readthedocs.io/en/master/) handles the current data in a [MongoDB](https://www.mongodb.com/) database.

Even though the software solution is designed to handle multiple Workstations, the Robo4Toys TTE needed to supervise one. A Siemens S7-15xx PLC controls the manufacturing cell that is treated as a unit. The PLC sends updates to the [R4T IoT agent for Siemens S7-15xx PLCs](https://github.com/aviharos/iotagent-http) that acts as an adapter between the PLC and the Orion Context Broker. Since in TIA Portal v16 one cannot define strings over 254 characters in length, the data packets need to be small. Our suggestion is that the objects are created some other way, and the PLC data packets cover only the changes in the objects. This is how the Orion Context Broker knows about the changes in the objects' attributes. If the command that we need to send to the PLC can be done using HTTP GET, POST and PUT, the R4T IoT agent is not needed. If the PLC sends HTTP DELETE requests, the IoT agent is needed. The Orion broker accepts HTTP PATCH commands, that are not yet implemented in the R4T IoT agent.

The Orion Context Broker notifies [Fiware Cygnus](https://github.com/FIWARE/tutorials.Historic-Context-Flume) whenever a component changes. Cygnus stores all historical data into a [PostgreSQL](https://www.postgresql.org/) historic database. The user needs to configure this notification when the docker project is started.

The [R4T OEE microservice](https://github.com/aviharos/oee) periodically calculates the OEE data and the throughput of each Workstation object and uploads it to a separate time-series OEE table in PostgreSQL. There is one table for each Workstation.

[Grafana](https://grafana.com/) is connected to the PostgreSQL. It is configured with custom dashboards. Operators and managers can be configured to have different privileges and different dashboards. Grafana is also configured to check certain values, and if they exceed or fall below a certain threshold, Grafana sends an alert to the operator about a task through [Discord](https://discord.com/). The Grafana configuration is covered in-depth in the official tutorials. We still need to find a solution for displaying the alert on the dashboard. 

The R4T ERP reporter microservice periodically checks if a Job is finished. If so, it sends an XML file to an SFTP server that the legacy ERP system can read (the ERP itself will be slightly extended). This microservice is yet to be written and tested.

Since the PLC will only modify object in the Orion context broker, the objects need to be created at startup. The Job objects will be created by the R4T Job uploader microservice, the rest will be created by sending the objects by Postman.

## How to adapt it?

The manufacturing processes, the Workstation, the shifts are all configured in JSON objects that need to be sent to the Orion context broker with cURL, Postman or another similar tool. The design of these objects must match the OEE [microservice's specifications](https://github.com/aviharos/oee#objects-in-the-orion-context-broker).

## How to deploy it?

Prerequisites:
 - Deployment requires [Docker Compose](https://docs.docker.com/compose/install/) v3.5 or above.
 - The OEE app needs to be [built](https://github.com/aviharos/oee#build) with docker
 - The IoT agent must be [built](https://github.com/aviharos/iotagent-http#build) with docker
 - During initial installation, internet access is required in order to download additional docker images according to [docker-compose.yml](docker-compose.yml)

Start docker project using docker-compose:

	docker-compose -f docker-compose.yml -p r4t up -d

## How to use it?

The environment variables (database login credentials, configuration, etc) need to be set in the [.env](.env) file.

Then the Orion Context Broker must be [configured to notify Cygnus](https://github.com/aviharos/oee#notifying-cygnus-of-all-context-changes) of all context changes.

At startup, each object's initial state needs to be uploaded to the Orion context broker. The representation of the manufacturing system, the jobs and the parts, etc. are defined here. The objects must match match the OEE microservice's [requirements](https://github.com/aviharos/oee#objects-in-the-orion-context-broker).

Whenever an attribute of an object changes, it must be updated in the Orion Context Broker. This can be done using the Siemens S7-15xx PLC's LHTTP library and HMI.

The Grafana dashboards needs to be set up according to the company's specific needs. Grafana uses PostgreSQL historic data.

## Environment Restrictions

## Known Limitations
The manufacturing processes must be able to translated into a Job-shop scheduling problem.

The ERP system still needs to be modified, the R4T OEE microservice needs to be refactored and thoroughly tested, the R4T Job uploader and the R4T ERP reporter microservice are yet to be written and tested.

The docker-compose file is under construction. It does not contain many microservices, including the R4T IoT agent microservice and the R4T OEE microservice. Currently, these can be added to the same network via `docker run`. The environment variables need to be moved to a separate `.env` file.

## Improvements Backlog

## License

[MIT license](LICENSE)

The Robo4Toys TTE does not hold any copyright of any FIWARE or 3rd party software.

## Version History

