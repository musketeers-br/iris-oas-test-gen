Class dc.musketeers.irisOasTestGen.integrationtests.TestHttpUtils Extends %UnitTest.TestCase
{

Parameter BasePath = "echo.free.beeceptor.com";

/// Test GET with query parameters
Method TestQuery()
{
    Set request = ##class(dc.musketeers.irisOasTestGen.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set request.HttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"
    Set response = request.SendRequest(
        "GET",
        "/testquery",
        "?foo=bar&baz=123"
    )
    Set responseData = response.Data.Read()

    // 1. Check for HTTP Status 200 OK
    Do $$$AssertEquals(200, response.StatusCode)
    // 2. Check if the response body contains the query parameters, indicating success
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER("foo=bar"))
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER("baz=123"))
}

/// Test POST with JSON body
Method TestBody()
{
    Set request = ##class(dc.musketeers.irisOasTestGen.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set request.HttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"

    Set expectedBody = "{""name"":""Jose"",""role"":""developer""}"
    Set body = ##class(%Stream.GlobalCharacter).%New()
    Do body.Write(expectedBody)

    Set response = request.SendRequest(
        "POST",
        "/testbody",
        "",
        body
    )
    Set responseData = response.Data.Read()
    Set responseData = {}.%FromJSON(responseData)
    Set responseData = responseData.%ToJSON()

    // 1. Check for HTTP Status 200 OK
    Do $$$AssertEquals(200, response.StatusCode)
    // 2. Check if the response body contains the sent JSON data
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER(expectedBody))
}

/// Test GET with custom headers
Method TestHeaders()
{
    Set request = ##class(dc.musketeers.irisOasTestGen.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set request.HttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"

    Set headerName = "X-Custom-Header"
    Set headerValue = "MyHeaderValue"

    Set headers = ##class(%ListOfDataTypes).%New()
    Do headers.Insert({"Name":(headerName),"Value":(headerValue)})

    Set response = request.SendRequest(
        "GET",
        "/testheaders",
        "",
        "",
        headers
    )
    Set responseData = response.Data.Read()

    // 1. Check for HTTP Status 200 OK
    Do $$$AssertEquals(200, response.StatusCode)
    // 2. Check if the response body contains the custom header name and value
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER(headerName))
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER(headerValue))
}

/// Test POST with x-www-form-urlencoded
Method TestForm()
{
    Set request = ##class(dc.musketeers.irisOasTestGen.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set request.HttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"

    Set formParams = ##class(%ListOfDataTypes).%New()
    Do formParams.Insert({"Name":"username","Value":"jose"})
    Do formParams.Insert({"Name":"password","Value":"secret"})

    Set response = request.SendRequest(
        "POST",
        "/testform",
        "",
        "",
        "",
        formParams
    )
    Set responseData = response.Data.Read()
    Set responseData = {}.%FromJSON(responseData)
    Set responseData = responseData.%ToJSON()
    
    // 1. Check for HTTP Status 200 OK
    Do $$$AssertEquals(200, response.StatusCode)
    // 2. Check if the response body contains the form fields
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER("""username"":""jose"""))
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER("""password"":""secret"""))
}

/// Test POST with multipart/form-data
Method TestMultipart()
{
    Set request = ##class(dc.musketeers.irisOasTestGen.HttpUtils).%New()
    Set request.BasePath = ..#BasePath
    Set request.HttpRequest.Https = 1
    Set request.HttpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"

    Set mp = ##class(%ListOfDataTypes).%New()

    Set filePath = "/tmp/photo.jpg"
    Set fileContent = "Hello Beeceptor!Testing multipart/form-data upload from IRIS."
    // Create the file content on the IRIS server
    // Note: Using $ZF(-1) or similar for file creation is environment-dependent.
    // For the test to pass, the file content must match the expected echo response.
    Do $ZF(-1, "echo -n '"_fileContent_"' > "_filePath) 
        
    // Add a file stream
    Set fileStream = ##class(%Stream.FileBinary).%New()
    Do fileStream.LinkToFile(filePath)
    Do mp.Insert({"Name":"file","Value":(fileStream),"Filename":"photo.jpg","ContentType":"image/jpeg"})

    // Add a text field
    Set descriptionValue = "Profile picture"
    Do mp.Insert({"Name":"description","Value":(descriptionValue)})

    Set response = request.SendRequest(
        "POST",
        "/testmultipart",
        "",
        "",
        "",
        "",
        mp
    )
    Set responseData = response.Data.Read()
    Set responseData = {}.%FromJSON(responseData)
    Set responseData = responseData.%ToJSON()
    
    // Clean up file
    Do $ZF(-1, "rm -f "_filePath)

    // --- Assertions ---
    // 1. Check for HTTP Status 200 OK
    Do $$$AssertEquals(200, response.StatusCode)
    // 2. Check if the response body contains the text field value
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER("description"))
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER(descriptionValue))
    // 3. Check if the response body contains the file content
    Do $$$AssertTrue($$$LOWER(responseData) [ $$$LOWER(fileContent))
}

}
