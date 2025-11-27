 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-oas-test-gen)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-oas-test-gen&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-oas-test-gen)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-oas-test-gen&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-oas-test-gen)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# 🚀 IrisOASTestGen: Automated ObjectScript REST Test Generation

This tool is an OpenAPI Generator designed specifically for Intersystems IRIS. It ingests an OpenAPI Specification (Swagger) document and automatically produces robust, maintainable, and executable **ObjectScript code** to validate your IRIS REST APIs.

**Key Features:**

* **Specification-Driven Testing:** Ensure your API implementation strictly adheres to the defined OAS contract.
* **ObjectScript Native:** Generates client-side testing classes ready to run directly within the IRIS environment.
* **Rapid Development:** Dramatically accelerates the creation of integration and regression test suites for IRIS REST services.
* **Comprehensive Coverage:** Supports validation of endpoints, parameters, request bodies, and expected response schemas.

**Target Audience:** IRIS developers, QA engineers, and DevOps teams looking to integrate automated testing into their Intersystems IRIS ObjectScript projects.

## Usage
Start a new dev repository with InterSystems IRIS using this one as a template.
Once you clone the new repo to your laptop and open VSCode (with the [InterSystems ObjectScript Extension Pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack) installed) you'll be able to start development immediately.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/intersystems-community/iris-oas-test-gen.git
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:
*Note: Users running containers on a Linux CLI, should use "docker compose" instead of "docker-compose"*
*See [Install the Compose plugin](https://docs.docker.com/compose/install/linux/)*



```
$ docker-compose up -d
```

To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```