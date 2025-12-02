 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-oas-test-gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# 🚀 IrisOASTestGen: Automated ObjectScript REST Test Generation

This tool is an OpenAPI Generator designed specifically for Intersystems IRIS. It ingests an OpenAPI Specification 2.0 (Swagger) document and automatically produces robust, maintainable, and executable **ObjectScript code** to validate your IRIS REST APIs.

> 🚧 Note: Some data types aren't still covered, like List and File. Those will be added in the next releases.

**Key Features:**

* **Specification-Driven Testing:** Ensure your API implementation strictly adheres to the defined OAS contract.
* **ObjectScript Native:** Generates client-side testing classes ready to run directly within the IRIS environment.
* **Rapid Development:** Helps to accelerate the creation of integration and regression test suites for IRIS REST services.
* **Comprehensive Coverage:** Supports validation of endpoints, parameters, request bodies, and expected response schemas.

**Target Audience:** IRIS developers, QA engineers, and DevOps teams looking to integrate automated testing into their Intersystems IRIS ObjectScript projects.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Usage

Clone/git pull the repo into any local directory

```shell
git clone https://github.com/musketeers-br/iris-oas-test-gen.git
cd iris-oas-test-gen
chmod -R o+w tests # allow container processes to write in the tests directory
```

Build and run InterSystems IRIS in container:
*Note: Users running containers on a Linux CLI, should use "docker compose" instead of "docker-compose"*
*See [Install the Compose plugin](https://docs.docker.com/compose/install/linux/)*

```shell
docker-compose up -d
```

With the container built and running, let's access the IRIS terminal

```shell
docker exec -it iris-oas-test-gen-iris-1 /bin/bash
```
```shell
iris session iris -U IRISAPP
```

Now, we can generate the tests classes. For this example, this [toy REST API specification](./assets/person-api.json) will be used.

```objectscript
Set openapiFile = "/home/irisowner/dev/assets/person-api.json"
Set outputDir = "/tmp/output"
Write ##class(dc.musketeers.irisOasTestGen.Main).Run(openapiFile, outputDir)
Halt
```

By default the output files are stored in `/tmp/output/src`. Let's copy them to the mounted volume and allow edition.

```shell
cp -r /tmp/output/src /home/irisowner/dev/tests
chmod -R o+w /home/irisowner/dev/tests/src # allow edition in the host machine
exit
```

Now open VSCode on the project dir.

```shell
code .
```

You can check the generated files inside dir tests.

![Model for tests created form the OpenAPI Specification](https://raw.githubusercontent.com/musketeers-br/iris-oas-test-gen/refs/heads/master/assets/img/person-model.png)

![API test created form the OpenAPI Specification](https://raw.githubusercontent.com/musketeers-br/iris-oas-test-gen/refs/heads/master/assets/img/person-api.png)

Now you have templates with client calls for each operation in the OpenAPI specification and the corresponding test method for your implementation. For instance:

```objectscript
/// Create a new Person record
/// OperationId: createPerson
Method CreatePerson(
    pPerson As model.Person) As %Net.HttpResponse
{
    Set path = "/"
    Set queryParams = ""
    Set bodyStream = ""
    Set headers = ##class(%ListOfDataTypes).%New()
    Set formParams = ##class(%ListOfDataTypes).%New()
    Set multipartParams = ##class(%ListOfDataTypes).%New()
    
    // Handle body
    $$$ThrowOnError(pPerson.%JSONExportToStream(.bodyStream))

    Set request = ##class(utils.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set httpResponse = request.SendRequest("POST", path, queryParams, bodyStream, headers, formParams, multipartParams)
    Return httpResponse
}

/// Unit test for createPerson
Method TestCreatePerson()
{
    // TODO:
    // Set pPerson = ""
    // Set httpResponse = ..CreatePerson(
    //     pPerson
    // )
}
```

## Custome template

todo:

## 🎖️ Credits
Artisan is developed with ❤️ by the Musketeers Team

* [José Roberto Pereira](https://community.intersystems.com/user/jos%C3%A9-roberto-pereira-0)
* [Henry Pereira](https://community.intersystems.com/user/henry-pereira)
* [Henrique Dias](https://community.intersystems.com/user/henrique-dias-2)

![3Musketeers-br](./assets/3musketeers.png)