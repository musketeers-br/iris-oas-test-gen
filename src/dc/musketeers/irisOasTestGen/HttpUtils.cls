Class dc.musketeers.irisOasTestGen.HttpUtils Extends %RegisteredObject
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
    If $IsObject(pHeaders) {
        For i=1:1:pHeaders.Count() {
            Set headerName = pHeaders.GetAt(i).Name
            Set headerValue = pHeaders.GetAt(i).Value
            Do httpRequest.SetHeader(headerName, headerValue)
        }
    }

    // Apply form parameters (x-www-form-urlencoded)
    If $IsObject(pFormParams) {
        For i=1:1:pFormParams.Count() {
            Set formName = pFormParams.GetAt(i).Name
            Set formValue = pFormParams.GetAt(i).Value
            Do httpRequest.InsertFormData(formName, formValue)
        }
        Set httpRequest.ContentType = "application/x-www-form-urlencoded"
    }

    // Apply multipart/form-data parameters
    If $IsObject(pMultipartParams) {
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
