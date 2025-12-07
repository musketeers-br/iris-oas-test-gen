# Project Overview / Introduction

Developing and testing REST APIs in **InterSystems IRIS** often requires a significant amount of boilerplate code. While ObjectScript provides powerful tools for building APIs, writing consistent and repeatable tests can be time‑consuming. This is where **IrisOASTestGen** comes in.

**IrisOASTestGen** is a utility designed to generate the **structure of test classes** and the **supporting utility code** directly from an **OpenAPI 2.0 specification**. It leverages the [**OpenAPITools openapi‑generator**](https://github.com/OpenAPITools/openapi-generator) under the hood to scaffold test stubs and helper methods that make it easier to interact with your API endpoints.  

It’s important to stress: IrisOASTestGen does **not** generate complete test logic. Instead, it provides the skeleton — the test class definitions, method signatures, and utility functions — so developers can focus on writing meaningful assertions and scenarios. Think of it as scaffolding: the framework is built for you, but the actual test cases remain in your hands.

---

# Demo REST API

For demonstration purposes, a toy API specification was created in the package [`dc.musketeers.irisOasTestGenDemo.personApi`](https://github.com/musketeers-br/iris-oas-test-gen/tree/master/src/dc/musketeers/irisOasTestGenDemo/personApi). The server implementation uses the InterSystems [`%REST.API`](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_INTRO) class. Below is the utility class that sets up the REST application based on the OpenAPI specification (complete code [here](https://github.com/musketeers-br/iris-oas-test-gen/blob/master/src/dc/musketeers/irisOasTestGenDemo/personApi/Utils.cls)):

```objectscript
ClassMethod CreateRestApi() As %Status
{
    Set sc = $$$OK
    Try {
        // Create the REST application based on the OpenAPI specification
        Set apiSpecPath = "/home/irisowner/dev/assets/person-api.json"
        Set spec = ##class(%DynamicObject).%FromJSONFile(apiSpecPath)
        $$$ThrowOnError(##class(%REST.API).CreateApplication("dc.musketeers.irisOasTestGenDemo.personApi", spec))

        // Deploy the REST application to the server
        Set restApplication = "dc.musketeers.irisOasTestGenDemo.personApi"
        Set webApplication = "/dc/musketeers/irisOasTestGenDemo/personApi"
        Set authenticationType = $$$AutheUnauthenticated
        #; Set matchRoles = ":%DB_IRISAPP-CODE:%DB_IRISAPP-DATA"
        Set matchRoles = ":%ALL"
        $$$ThrowOnError(##class(dc.musketeers.irisOasTestGenDemo.Utils).DeployApplication(restApplication, webApplication, authenticationType, matchRoles))
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    return sc
}
```

The actual server implementation can be found in the class [`dc.musketeers.irisOasTestGenDemo.personApi.impl`](https://github.com/musketeers-br/iris-oas-test-gen/blob/master/src/dc/musketeers/irisOasTestGenDemo/personApi/impl.cls).

---

# Usage Walkthrough

With the demo REST API in place, let’s walk through how **IrisOASTestGen** scaffolds the test structure and utilities. Remember: the tool generates **test stubs and helper methods**, not the actual test logic. You’ll add assertions and scenarios yourself.

---

## 1. Generating Test Files

The entry point for generating test scaffolding is: 

`##class(dc.musketeers.irisOasTestGen.Main).BuildAndDeploy(openapiFile, outputDir, packageName)`

Parameters:
- `openapiFile` — path to the OpenAPI specification file.  
- `outputDir` — optional directory for generated code.  
- `packageName` — optional package name for generated classes.  

For convenience, the demo project includes a [helper method](https://github.com/musketeers-br/iris-oas-test-gen/blob/master/src/dc/musketeers/irisOasTestGenDemo/personApi/Utils.cls):

```objectscript
Class dc.musketeers.irisOasTestGenDemo.personApi.Utils Extends %RegisteredObject
{

ClassMethod Build()
{
    // OpenAPI Spec location
    Set openapiFile = "/home/irisowner/dev/assets/person-api.json"
    // Directory where the files will be written
    Set outputDir = "/home/irisowner/dev/tests"
    // Generated files package name
    Set packageName = "dc.musketeers.irisOasTestGenDemo.personApi.tests"
    // Run the generator
    Write ##class(dc.musketeers.irisOasTestGen.Main).BuildAndDeploy(openapiFile, outputDir, packageName)
}

}
```

Access the IRIS terminal and execute:

> Note: this tutorial expects you had an IRIS container built using the steps detailed [here](https://github.com/musketeers-br/iris-oas-test-gen?tab=readme-ov-file#-basic-usage).

```objectscript
ZN "IRISAPP"
Do $SYSTEM.OBJ.Import("/home/irisowner/dev/src/dc/musketeers/irisOasTestGenDemo", "ck")
Do ##class(dc.musketeers.irisOasTestGenDemo.personApi.Utils).CreateRestApi()
Do ##class(dc.musketeers.irisOasTestGenDemo.personApi.Utils).Build()
```

If all works as expected, you'll see this output:

```
[main] INFO  o.o.codegen.DefaultGenerator - Generating with dryRun=false
[main] INFO  o.o.c.ignore.CodegenIgnoreProcessor - No .openapi-generator-ignore file found.
[main] INFO  o.o.codegen.DefaultGenerator - OpenAPI Generator: iris-object-script (other)
[main] INFO  o.o.codegen.DefaultGenerator - Generator 'iris-object-script' is considered stable.
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/./dc/musketeers/irisOasTestGenDemo/personApi/tests/model/Error.cls
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/./dc/musketeers/irisOasTestGenDemo/personApi/tests/model/Person.cls
[main] WARN  o.o.codegen.utils.ExamplesUtils - No application/json content media type found in response. Response examples can currently only be generated for application/json media type.
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/./dc/musketeers/irisOasTestGenDemo/personApi/tests/api/PersonApi.cls
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/./dc/musketeers/irisOasTestGenDemo/personApi/tests/utils/HttpUtils.cls
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/.openapi-generator-ignore
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/.openapi-generator/VERSION
[main] INFO  o.o.codegen.TemplateManager - writing file /home/irisowner/dev/tests/.openapi-generator/FILES
############################################################################################
# Thanks for using OpenAPI Generator.                                                      #
# We appreciate your support! Please consider donation to help us maintain this project.   #
# https://opencollective.com/openapi_generator/donate                                      #
############################################################################################

Load of directory started on 12/07/2025 01:54:34

Loading file /home/irisowner/dev/tests/dc/musketeers/irisOasTestGenDemo/personApi/tests/model/Person.cls as udl
Loading file /home/irisowner/dev/tests/dc/musketeers/irisOasTestGenDemo/personApi/tests/model/Error.cls as udl
Loading file /home/irisowner/dev/tests/dc/musketeers/irisOasTestGenDemo/personApi/tests/utils/HttpUtils.cls as udl
Loading file /home/irisowner/dev/tests/dc/musketeers/irisOasTestGenDemo/personApi/tests/api/PersonApi.cls as udl
Load finished successfully.
```

---

## 2. Exploring Generated Files

After running the generator, you’ll find a set of test classes and utilities scaffolded for your API. You can find those files in generated directory `tests/dc/musketeers/irisOasTestGenDemo`.

![Generated test files](https://raw.githubusercontent.com/musketeers-br/iris-oas-test-gen/refs/heads/master/assets/img/generated_test_files.png)

The OpenAPI Tool Generator generates one test class per path described in the `paths` section of the OpenAPI 2.0 spec.

As [our toy example API](https://github.com/musketeers-br/iris-oas-test-gen/blob/master/assets/person-api.json) has just one path, only one test class is created: `TestsPersonApi.cls`. It has one test for each endpoint and uses the `operationId` property to name the test.

The tool also generates model classes for data structures defined in the `definitions` section. In our case, the models `Person.cls` and `Error.cls` was created.

Finally, an utility class to abstract HTTP operations is also generated: `HttpUtils.cls`.

### 2.1 Test Stub Class

As said, our API has just one path with several operations, so just one test class is generated: `TestsPersonApi.cls`.

Let's start with the test for operation `createPerson`. Its OpenAPI 2.0 definition fragment is displayed below:

```json
"post": {
  "tags": [
    "Person"
  ],
  "summary": "Create a new Person record",
  "operationId": "createPerson",
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "parameters": [
    {
      "name": "person",
      "in": "body",
      "description": "Person object to be created",
      "required": true,
      "schema": {
        "$ref": "#/definitions/Person"
      }
    }
  ],
  "responses": {
    "201": {
      "description": "Person created successfully",
      "schema": {
        "$ref": "#/definitions/Person"
      },
      "headers": {
        "Location": {
          "description": "The full URI of the newly created Person resource. E.g. /dc/musketeers/irisOasTestGenDemo/personApi/1",
          "type": "string"
        }
      }
    },
    "400": {
      "description": "Invalid input",
      "schema": {
        "$ref": "#/definitions/Error"
      }
    }
  }
},
```

You can see that the generator creates a method called `TestCreatePerson()` with the stub for you implementation:

```objectscript
Class dc.musketeers.irisOasTestGenDemo.personApi.tests.api.TestsPersonApi Extends %UnitTest.TestCase
{
    /// Test for createPerson
    Method TestCreatePerson()
    {
        // TODO:
        // Set pPerson = ""
        // Set httpResponse = ..CreatePerson(
        //     pPerson
        // )
    }
}
```

Notice that the method is just a **placeholder**. IrisOASTestGen gives you the structure; you add the test logic.

---

### 2.2 Utility Method

The generator also creates convenience methods for each API operation. For example, `CreatePerson()`:

```objectscript
Class dc.musketeers.irisOasTestGenDemo.personApi.tests.api.TestsPersonApi Extends %UnitTest.TestCase
{

/// Create a new Person record
/// OperationId: createPerson
Method CreatePerson(pPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person) As %Net.HttpResponse
{
    Set path = "/"
    Set queryParams = ""
    Set bodyStream = ""
    Set headers = ##class(%ListOfDataTypes).%New()
    Set formParams = ##class(%ListOfDataTypes).%New()
    Set multipartParams = ##class(%ListOfDataTypes).%New()

    // Handle body
    $$$ThrowOnError(pPerson.%JSONExportToStream(.bodyStream))

    Set request = ##class(dc.musketeers.irisOasTestGenDemo.personApi.tests.utils.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set httpResponse = request.SendRequest("POST", path, queryParams, bodyStream, headers, formParams, multipartParams)
    Return httpResponse
}

}
```

This method abstracts away the HTTP request details, so your tests can focus on assertions.

---

### 2.3 Supporting Utilities

The `HttpUtils` class is also generated, providing a reusable way to send requests:

```objectscript
Class dc.musketeers.irisOasTestGenDemo.personApi.tests.utils.HttpUtils Extends %RegisteredObject
{

Property HttpRequest As %Net.HttpRequest;

Property BasePath As %String;

Method %OnNew() As %Status
{
    Set ..HttpRequest = ##class(%Net.HttpRequest).%New()
    Set ..HttpRequest.Https = 0
    Set ..HttpRequest.Username = "_system"
    Set ..HttpRequest.Password = "SYS"
    Set ..HttpRequest.ContentType = "application/json"
    Return $$$OK
}

/// Common method to execute an HTTP request
Method SendRequest(pMethod As %String, pPath As %String, pQueryParams As %String = "", pBody As %Stream.Object = "", pHeaders As %ListOfDataTypes = "", pFormParams As %ListOfDataTypes = "", pMultipartParams As %ListOfDataTypes = "") As %Net.HttpResponse
{
    Set httpRequest = ..HttpRequest
    Set httpRequest.Server = ..BasePath

    // Apply headers
    If ($IsObject(pHeaders)) && (pHeaders.Count() > 0) {
        For i=1:1:pHeaders.Count() {
            Set headerName = pHeaders.GetAt(i).Name
            Set headerValue = pHeaders.GetAt(i).Value
            Do httpRequest.SetHeader(headerName, headerValue)
        }
    }

    // Apply form parameters (x-www-form-urlencoded)
    If ($IsObject(pFormParams)) && (pFormParams.Count() > 0) {
        For i=1:1:pFormParams.Count() {
            Set formName = pFormParams.GetAt(i).Name
            Set formValue = pFormParams.GetAt(i).Value
            Do httpRequest.InsertFormData(formName, formValue)
        }
        Set httpRequest.ContentType = "application/x-www-form-urlencoded"
    }

    // Apply multipart/form-data parameters
    If ($IsObject(pMultipartParams)) && (pMultipartParams.Count() > 0) {
        For i=1:1:pMultipartParams.Count() {
            Set part = pMultipartParams.GetAt(i)
            // Expect each part to have Name, Value, and optionally Filename/ContentType
            Do httpRequest.InsertFormData(part.Name, part.Value)
        }
        // ContentType will be set automatically to multipart/form-data with boundary
    }

    Set path = $PIECE(pPath, "?", 1)
    Set fullPath = ..BasePath _ path _ pQueryParams
    
    If (pMethod = "POST") {
        If ($IsObject(pBody)) {
            $$$ThrowOnError(httpRequest.EntityBody.CopyFrom(pBody))
        }
        $$$ThrowOnError(httpRequest.Post(fullPath))

    } ElseIf (pMethod = "GET") {
        $$$ThrowOnError(httpRequest.Get(fullPath))

    } ElseIf (pMethod = "PUT") {
        If ($IsObject(pBody)) {
            $$$ThrowOnError(httpRequest.EntityBody.CopyFrom(pBody))
        }
        Set httpResponse = httpRequest.Put(fullPath)

    } ElseIf (pMethod = "DELETE") {
        Set httpResponse = httpRequest.Delete(fullPath)

    } Else {
        Throw ##class(%Exception.General).%New("Unsupported HTTP method: " _ pMethod)
    }
    
    Return httpRequest.HttpResponse
}

}
```

It supports all kind of [parameters allowed by OpenAPI 2.0 specification](https://spec.openapis.org/oas/v2.0.html#parameter-object).

---

## 3. Implementing a Test

Now let’s implement the `TestCreatePerson()` method.

The operation definition in the specification defines the allowed input parameters and their expected outputs - with HTTP status codes and data structures. Let's create test code for each of them.

Replace the comments generated scaffold in the method `TestCreatePerson()` in class `dc.musketeers.irisOasTestGenDemo.personApi.tests.api.TestsPersonApi` by the following code:

```objectscript
/// Test for createPerson
Method TestCreatePerson()
{
    // Define the valid input Person object
    #Dim person As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()

    Set person.Name = "John Doe"
    Set person.Title = "Software Engineer"
    Set person.Company = "InterSystems"
    Set person.Phone = "555-123-4567"
    Set person.DOB = $zdateh("2000-01-01", 3) 

    // Execute the operation
    Set httpResponse = ..CreatePerson(
        person
    )
    
    // Parse the JSON Response
    Set responseString = httpResponse.Data.Read()
    #dim createdPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = createdPerson.%JSONImport(responseString)
    
    // 1. Status Code Check
    Do $$$AssertEquals(httpResponse.StatusCode, 201, "CreatePerson: Should return 201 Created")

    // 2. Response Body Type Check
    Do $$$AssertStatusOK(sc, "CreatePerson: Response should be a valid Person object")
    
    // 3. Response Body Content Check
    Do $$$AssertEquals(createdPerson.Name, person.Name, "CreatePerson: Response body Name should match input Name")
    
    // Corrected check for the presence of the ID:
    // Assert that the ID property is not an empty string ("") after successful creation.
    Do $$$AssertNotEquals(createdPerson.ID, "", "CreatePerson: Response body should contain a non-empty ID after creation")

    // 4. Response Header Check (Location header)
    Set locationHeader = httpResponse.GetHeader("Location")
    Do $$$AssertNotEquals(locationHeader, "", "CreatePerson: Response should include a Location header")
    Do $$$AssertTrue((locationHeader [ createdPerson.ID), "CreatePerson: Location header should contain the newly created ID")

    // --- Negative case: 400 Bad Request for invalid input ---
    // Create an invalid or incomplete Person object
    #dim invalidPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()

    // Execute the operation with the invalid object
    Set httpResponse = ..CreatePerson(
        invalidPerson
    )

    // --- Parse the JSON Error Response ---
    // Read the response data stream into a string
    Set errorString = httpResponse.Data.Read()
    // Convert the string into a dynamic object
    #dim error As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = error.%JSONImport(errorString)

    // --- Assertions for 400 Bad Request ---
    
    // 1. Status Code Check
    Do $$$AssertEquals(httpResponse.StatusCode, 400, "CreatePerson: Should return 400 Bad Request for invalid input")

    // 2. Response Body Type Check
    Do $$$AssertStatusOK(sc, "CreatePerson: Response should be a valid Error object")

    // 3. Response Body Content Check
    // Verify the structure of the returned Error object matches the implementation:
    // {"code":400,"message":...}
    Do $$$AssertEquals(error.code, 400, "CreatePerson: Error object 'code' should be 400")
    
    // 4. Error Message Check
    // Verify that the 'message' field is present and is a string (containing the error details).
    Do $$$AssertNotEquals(error.message, "", "CreatePerson: Error object 'message' should be a string containing the error details")
}
```

---

## 4. Running the Tests

After implemented the tests for `createPerson` operation, let's execute the test suite:

```objectscript
ZN "IRISAPP"
Do ##class(dc.musketeers.irisOasTestGenDemo.personApi.Utils).RunTests()
```

This is a convenince method which encapsulates the calling to IRIS `%UnitTest` framework. You can check out its code [here](https://github.com/musketeers-br/iris-oas-test-gen/blob/master/src/dc/musketeers/irisOasTestGenDemo/personApi/Utils.cls).

If all went as expected, you'll see an output with assertions:

```
...
    dc.musketeers.irisOasTestGenDemo.personApi.tests.api.TestsPersonApi begins ...
      TestCreatePerson() begins ...
        AssertEquals:CreatePerson: Should return 201 Created (passed)
        AssertStatusOK:CreatePerson: Response should be a valid Person object (passed)
        AssertEquals:CreatePerson: Response body Name should match input Name (passed)
        AssertNotEquals:CreatePerson: Response body should contain a non-empty ID after creation (passed)
        AssertNotEquals:CreatePerson: Response should include a Location header (passed)
        AssertTrue:CreatePerson: Location header should contain the newly created ID (passed)
        AssertEquals:CreatePerson: Should return 400 Bad Request for invalid input (passed)
        AssertStatusOK:CreatePerson: Response should be a valid Error object (passed)
        AssertEquals:CreatePerson: Error object 'code' should be 400 (passed)
        AssertNotEquals:CreatePerson: Error object 'message' should be a string containing the error details (passed)
        LogMessage:Duration of execution: .01195 sec.
      TestCreatePerson passed
      ...
    dc.musketeers.irisOasTestGenDemo.personApi.tests.api.TestsPersonApi passed
...
```

---

## 5. Completing the test implementation

Now we walked through all steps to implement and run a test for an operation, let's implement those for all the other operations.

First, let's add a clean up code to be executed after each test. Thus we guarantee that the ouput of one previous test don't affects the execution of the current one. So, edit the `OnAfterOneTest()` method like this:

```objectscript
/// Cleanup method for each test
Method OnAfterOneTest() As %Status
{
	Do ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%KillExtent()
	Return $$$OK
}
```

Now, we're all set to implement the tests for the others API operations.

Tests for `getPersonById`:
```objectscript
/// Test for getPersonById
Method TestGetPersonById()
{
    // --- Arrange: create a Person to have a valid ID ---
    #Dim person As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set person.Name = "Jane Doe"
    Set person.Title = "Product Manager"
    Set person.Company = "InterSystems"
    Set person.Phone = "555-987-6543"
    Set person.DOB = $zdateh("1990-05-10", 3)

    // Execute the create operation
    Set httpCreate = ..CreatePerson(person)

    // Parse create response
    Set createString = httpCreate.Data.Read()
    #dim createdPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = createdPerson.%JSONImport(createString)

    // --- Assertions for 201 Created ---
    Do $$$AssertStatusOK(sc, "Person object for the test should be created successfully")
    Do $$$AssertNotEquals(createdPerson.ID, "201", "Should return a valid ID after creation")

    // --- Act: retrieve the Person by ID ---
    Set pId = createdPerson.ID
    Set httpResponse = ..GetPersonById(pId)

    // Parse get response
    Set responseString = httpResponse.Data.Read()
    #dim retrievedPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = retrievedPerson.%JSONImport(responseString)

    // --- Assertions for 200 OK ---
    Do $$$AssertEquals(httpResponse.StatusCode, 200, "GetPersonById should return 200 OK")
    Do $$$AssertEquals($IsObject(retrievedPerson), 1, "GetPersonById response should be a parsed JSON object")
    Do $$$AssertEquals(retrievedPerson.ID, pId, "GetPersonById: ID should match requested ID")
    Do $$$AssertEquals(retrievedPerson.Name, person.Name, "GetPersonById: Name should match the created record")
    Do $$$AssertEquals(retrievedPerson.Title, person.Title, "GetPersonById: Title should match the created record")
    Do $$$AssertEquals(retrievedPerson.Company, person.Company, "GetPersonById: Company should match the created record")
    Do $$$AssertEquals(retrievedPerson.Phone, person.Phone, "GetPersonById: Phone should match the created record")

    // Headers per OpenAPI: ETag and Cache-Control should be present and non-empty
    Set etag = httpResponse.GetHeader("ETag")
    Set cacheControl = httpResponse.GetHeader("Cache-Control")
    Do $$$AssertNotEquals(etag, "", "GetPersonById: ETag header should be present")
    Do $$$AssertNotEquals(cacheControl, "", "GetPersonById: Cache-Control header should be present")

    // --- Negative case: 404 Not Found for a non-existent ID ---
    // Choose an unlikely ID (assuming OIDs are positive integers)
    Set missingId = 987654321
    Set httpMissing = ..GetPersonById(missingId)

    // Parse missing response (expected Error schema)
    Set missingString = httpMissing.Data.Read()
    #; Set missingBody = ##class(%DynamicObject).%FromJSON(missingString)
    #dim error As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = error.%JSONImport(missingString)

    Do $$$AssertEquals(httpMissing.StatusCode, 404, "GetPersonById should return 404 for non-existent ID")
    Do $$$AssertStatusOK(sc, "GetPersonById: Response should be a valid Error object")
    Do $$$AssertEquals(error.code, 404, "GetPersonById: Error code should be 404")
    Do $$$AssertNotEquals(error.message, "", "GetPersonById: Error message should be non-empty")
}
```

Tests for `listPeople`:
```objectscript
/// Test for listPeople
Method TestListPeople()
{
    // --- Precondition: after cleanup, the list should be empty ---
    Set httpEmpty = ..ListPeople()
    Set emptyString = httpEmpty.Data.Read()
    #Dim emptyArray As %DynamicArray = ##class(%DynamicArray).%FromJSON(emptyString)

    Do $$$AssertEquals(httpEmpty.StatusCode, 200, "ListPeople should return 200 OK even when empty")
    Do $$$AssertTrue($IsObject(emptyArray), "ListPeople empty response should be a valid JSON array")
    Do $$$AssertEquals(emptyArray.%Size(), 0, "ListPeople should return an empty array when no Person records exist")

    // --- Arrange: create a few Person records to ensure the list is non-empty ---
    #Dim person1 As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set person1.Name = "Alice Example"
    Set person1.Title = "QA Engineer"
    Set person1.Company = "InterSystems"
    Set person1.Phone = "555-111-2222"
    Set person1.DOB = $zdateh("1995-07-20", 3)
    Set httpCreate1 = ..CreatePerson(person1)

    #Dim person2 As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set person2.Name = "Bob Example"
    Set person2.Title = "Developer"
    Set person2.Company = "InterSystems"
    Set person2.Phone = "555-333-4444"
    Set person2.DOB = $zdateh("1988-03-15", 3)
    Set httpCreate2 = ..CreatePerson(person2)

    // --- Act: call the ListPeople operation ---
    Set httpResponse = ..ListPeople()

    // --- Parse the JSON array response ---
    Set responseString = httpResponse.Data.Read()
    #Dim peopleArray As %DynamicArray = ##class(%DynamicArray).%FromJSON(responseString)

    // --- Assertions for 200 OK ---
    Do $$$AssertEquals(httpResponse.StatusCode, 200, "ListPeople should return 200 OK")
    Do $$$AssertTrue($IsObject(peopleArray), "ListPeople response should be a valid JSON array")

    // The array should contain exactly 2 elements (since we created 2 persons above)
    Do $$$AssertEquals(peopleArray.%Size(), 2, "ListPeople should return 2 Person records")

    // --- Validate that returned objects have required fields ---
    #Dim firstPerson As %DynamicObject = peopleArray.%Get(1)
    Do $$$AssertNotEquals(firstPerson.ID, "", "ListPeople: Each Person should have a non-empty ID")
    Do $$$AssertNotEquals(firstPerson.Name, "", "ListPeople: Each Person should have a non-empty Name")
}
```

Tests for `updatePerson`:
```objectscript
/// Test for updatePerson
Method TestUpdatePerson()
{
    // --- Arrange: create a Person to update ---
    #Dim person As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set person.Name = "Charlie Original"
    Set person.Title = "Intern"
    Set person.Company = "InterSystems"
    Set person.Phone = "555-000-1111"
    Set person.DOB = $zdateh("2001-09-09", 3)

    Set httpCreate = ..CreatePerson(person)

    // Parse create response
    Set createString = httpCreate.Data.Read()
    #Dim createdPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = createdPerson.%JSONImport(createString)

    Do $$$AssertStatusOK(sc, "UpdatePerson: Person object for the test should be created successfully")
    Do $$$AssertNotEquals(createdPerson.ID, "", "UpdatePerson: Created Person should have a non-empty ID")

    // --- Act: update the Person record ---
    Set pId = createdPerson.ID
    #Dim updatedPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set updatedPerson.ID = pId
    Set updatedPerson.Name = "Charlie Updated"
    Set updatedPerson.Title = "Software Developer"
    Set updatedPerson.Company = "InterSystems Corp"
    Set updatedPerson.Phone = "555-999-8888"
    Set updatedPerson.DOB = $zdateh("2001-09-09", 3)

    Set httpResponse = ..UpdatePerson(pId, updatedPerson)

    // Parse update response
    Set responseString = httpResponse.Data.Read()
    #Dim returnedPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = returnedPerson.%JSONImport(responseString)

    // --- Assertions for 200 OK ---
    Do $$$AssertEquals(httpResponse.StatusCode, 200, "UpdatePerson should return 200 OK")
    Do $$$AssertStatusOK(sc, "UpdatePerson: Response should be a valid Person object")
    Do $$$AssertEquals(returnedPerson.ID, pId, "UpdatePerson: ID should remain unchanged after update")
    Do $$$AssertEquals(returnedPerson.Name, updatedPerson.Name, "UpdatePerson: Name should be updated")
    Do $$$AssertEquals(returnedPerson.Title, updatedPerson.Title, "UpdatePerson: Title should be updated")
    Do $$$AssertEquals(returnedPerson.Company, updatedPerson.Company, "UpdatePerson: Company should be updated")
    Do $$$AssertEquals(returnedPerson.Phone, updatedPerson.Phone, "UpdatePerson: Phone should be updated")

    // --- Negative case: 400 Bad Request for ID mismatch ---
    #Dim mismatchPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set mismatchPerson.ID = pId + 1
    Set mismatchPerson.Name = "Mismatch Name"

    Set httpMismatch = ..UpdatePerson(pId, mismatchPerson)
    Set mismatchString = httpMismatch.Data.Read()
    #Dim error400 As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = error400.%JSONImport(mismatchString)

    Do $$$AssertEquals(httpMismatch.StatusCode, 400, "UpdatePerson should return 400 Bad Request for ID mismatch")
    Do $$$AssertStatusOK(sc, "UpdatePerson: Response should be a valid Error object for mismatch")
    Do $$$AssertEquals(error400.code, 400, "UpdatePerson: Error code should be 400")
    Do $$$AssertNotEquals(error400.message, "", "UpdatePerson: Error message should be non-empty")

    // --- Negative case: 404 Not Found for non-existent ID ---
    Set missingId = 987654321
    #Dim missingPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set missingPerson.ID = missingId
    Set missingPerson.Name = "Ghost Person"

    Set httpMissing = ..UpdatePerson(missingId, missingPerson)
    Set missingString = httpMissing.Data.Read()
    #Dim error404 As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = error404.%JSONImport(missingString)

    Do $$$AssertEquals(httpMissing.StatusCode, 404, "UpdatePerson should return 404 Not Found for non-existent ID")
    Do $$$AssertStatusOK(sc, "UpdatePerson: Response should be a valid Error object for missing ID")
    Do $$$AssertEquals(error404.code, 404, "UpdatePerson: Error code should be 404")
    Do $$$AssertNotEquals(error404.message, "", "UpdatePerson: Error message should be non-empty")
}
```

Tests for `deletePerson`:
```objectscript
/// Test for deletePerson
Method TestDeletePerson()
{
    // --- Arrange: create a Person to delete ---
    #Dim person As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set person.Name = "Delete Me"
    Set person.Title = "Temp"
    Set person.Company = "InterSystems"
    Set person.Phone = "555-444-5555"
    Set person.DOB = $zdateh("1999-12-31", 3)

    Set httpCreate = ..CreatePerson(person)

    // Parse create response
    Set createString = httpCreate.Data.Read()
    #Dim createdPerson As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Person).%New()
    Set sc = createdPerson.%JSONImport(createString)

    Do $$$AssertStatusOK(sc, "DeletePerson: Person object for the test should be created successfully")
    Do $$$AssertNotEquals(createdPerson.ID, "", "DeletePerson: Created Person should have a non-empty ID")

    // --- Act: delete the Person record ---
    Set pId = createdPerson.ID
    Set httpResponse = ..DeletePerson(pId)

    // --- Assertions for 204 No Content ---
    Do $$$AssertEquals(httpResponse.StatusCode, 204, "DeletePerson should return 204 No Content on successful deletion")

    // --- Verify that the Person no longer exists ---
    Set httpGet = ..GetPersonById(pId)
    Set getString = httpGet.Data.Read()
    #Dim error404 As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = error404.%JSONImport(getString)

    Do $$$AssertEquals(httpGet.StatusCode, 404, "DeletePerson: Subsequent GetPersonById should return 404 after deletion")
    Do $$$AssertStatusOK(sc, "DeletePerson: Response should be a valid Error object after deletion")
    Do $$$AssertEquals(error404.code, 404, "DeletePerson: Error code should be 404 after deletion")
    Do $$$AssertNotEquals(error404.message, "", "DeletePerson: Error message should be non-empty after deletion")

    // --- Negative case: delete a non-existent ID ---
    Set missingId = 987654321
    Set httpMissing = ..DeletePerson(missingId)
    Set missingString = httpMissing.Data.Read()
    #Dim errorMissing As dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error = ##Class(dc.musketeers.irisOasTestGenDemo.personApi.tests.model.Error).%New()
    Set sc = errorMissing.%JSONImport(missingString)

    Do $$$AssertEquals(httpMissing.StatusCode, 404, "DeletePerson should return 404 Not Found for non-existent ID")
    Do $$$AssertStatusOK(sc, "DeletePerson: Response should be a valid Error object for missing ID")
    Do $$$AssertEquals(errorMissing.code, 404, "DeletePerson: Error code should be 404 for missing ID")
    Do $$$AssertNotEquals(errorMissing.message, "", "DeletePerson: Error message should be non-empty for missing ID")
}
```

---

# Limitations / Roadmap

While **IrisOASTestGen** provides scaffolding for test classes and utilities, there are some current limitations to be aware of:

- **Complex types** such as `object`, `array`, and `file` are not yet fully supported in generated test scaffolding.  
- The generated stubs focus on **basic request/response structures**; developers must still implement the full test logic, including assertions for complex payloads.  
- Advanced customization of the generated code relies on **mustache templates**. These templates can be tailored to specific project needs, but that topic deserves its own deep dive.  

---

# Conclusion

**IrisOASTestGen** is an attempt to streamline the process of setting up test scaffolding for REST APIs in InterSystems IRIS. By generating the **structure of test classes** and **utility methods** directly from an OpenAPI 2.0 specification, it removes the repetitive boilerplate work and lets developers focus on what matters most: writing meaningful test logic and assertions.

In this walkthrough, we saw how to:
- Create a demo REST API using `%REST.API`.  
- Generate test scaffolding with `BuildAndDeploy` or the convenience `Build()` method.  
- Explore the generated test stubs and utility classes (`TestsPersonApi`, `CreatePerson()`, `HttpUtils`).  
- Implement a sample test (`TestCreatePerson()`) and run the suite with assertions.  

The key takeaway: IrisOASTestGen is a **scaffolding tool**. It builds the skeleton and equips you with utilities, but the creative responsibility of designing robust test cases remains yours.  

---