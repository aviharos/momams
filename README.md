# Manufacturing_OEE_alert_management_system (MOAMS)

## Purpose

MOAMS provides a system for
- logging manufacturing systems,
- calculating OEE values,
- OEE visualisation and
- sending alerts for operators about upcoming tasks.

## Overview
The system was developed as a part of a  [DIH²](http://dih-squared.eu/) project.
Developed by the Robo4Toys (R4T) TTE: Robo-Tech Service Ltd.](https://robo-tech.hu/en/), [Artrade Ltd.](https://shop.rubik.hu/en/).

The system is capable of handling manufacturing systems that
- match the criteria of the [Job-shop scheduling problem](https://en.wikipedia.org/wiki/Job-shop_scheduling),
- is capable of constantly updating the objects in the Orion context broker.

## Architecture and modules
The overall architecture is shown below: 
![MOAMS architecture and modules]()

The software components can be separated into 3 groups: 
- Fiware software components
- 3rd party software
- Custom TTE software.

The [R4T OEE microservice](https://github.com/aviharos/oee) and the [R4T IoT agent for Siemens S7-15xx PLCs](https://github.com/aviharos/iotagent-plc) are microsercices that can be used integrated into the MOAMS system or without integration.

The software components cooperate as follows.

The [Orion Context Broker](https://github.com/Fiware/tutorials.Getting-Started) holds the current data in a [MongoDB](https://www.mongodb.com/) database.

A Siemens S7-15xx PLC controls the manufacturing cell. The PLC sends updates to the [R4T IoT agent for Siemens S7-15xx PLCs](https://github.com/aviharos/iotagent-plc) that acts as an adapter between the PLC and the Orion Context Broker. Since it is likely that the PLC cannot handle strings over 254 characters in length, the data packets need to be small, covering only the changes in the objects. This is how the Orion Context Broker know about the changes in the objects' attributes. If the command that we need to send to the PLC can be done using HTTP GET, POST and PUT, maybe the R4T IoT agent is not needed at all. Further testing needs to be done about the Siemens S7-15xx PLCs' LHTTP module's capabilities.

The Orion Context Broker notifies [Fiware Cygnus](https://github.com/FIWARE/tutorials.Historic-Context-Flume) whenever a component changes. Cygnus stores all historical data into a [PostgreSQL](https://www.postgresql.org/) historic database.

The [R4T OEE microservice](https://github.com/aviharos/oee) periodically calculates the OEE data and the throughput of each Workstation object and uploads it to a separate time-series OEE table in PostgreSQL.

[Grafana](https://grafana.com/) is connected to the PostgreSQL. It is configured with custom dashboards. It is also configured to check certain values, and if they exceed or fall below a certain threshold, Grafana sends an alert to the operator about a task through [Discord](https://discord.com/). The Grafana configuration is covered in-depth in the official tutorials.

The R4T ERP reporter microservice periodically checks if a Job is finished. If so, it sends an XML file to an SFTP server that the legacy ERP system can read.

## How to adapt it?

The manufacturing processes, the Workstation, the shifts are all configured in JSON objects that need to be sent to the Orion context broker with cURL, Postman or another similar tool. The design of these objects must match the OEE [microservice's specifications](https://github.com/aviharos/oee#objects-in-the-orion-context-broker).

## How to deploy it?

Prerequisites:
 - Deployment requires [Docker Compose](https://docs.docker.com/compose/install/) v3.8 or above.
 - The OEE app needs to be [built](https://github.com/aviharos/oee#build) with docker
 - If the IoT agent is needed, it must be [built](https://github.com/aviharos/iotagent-plc#build) with docker
 - During initial installation, internet access is required in order to download additional docker images according to [docker-compose.yml](docker-compose.yml)

Start docker project using docker-compose:

	docker-compose -f docker-compose.yml --env-file .env -p r4t up -d

## How to use it?

The environment variables (database login credentials, configuration, etc) need to be set in the [.env](.env) file.

At startup, each object's initial state needs to be uploaded to the Orion context broker. The representation of the manufacturing system, the jobs and the parts, etc. are defined here. The objects must match match the OEE microservice's [requirements](https://github.com/aviharos/oee#objects-in-the-orion-context-broker).

Whenever an attribute of an object changes, it must be updated in the Orion Context Broker. This can be done using the Siemens S7-15xx PLC's LHTTP library and HMI.

The Grafana dashboards needs to be set up according to the company's specific needs. Grafana uses PostgreSQL historic data.

## Environment Restrictions

## Known Limitations
The manufacturing processes must be able to translated into a Job-shop scheduling problem.

## Improvements Backlog

## License
No license yet. The Robo4Toys TTE does not hold any copyright of any FIWARE or 3rd party software.

## Version History

