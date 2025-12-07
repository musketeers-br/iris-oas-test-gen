/// Simple CRUD operations Person model with arrays and file upload<br/>
/// Business logic class defined by OpenAPI in dc.musketeers.irisOasTestGenDemo.personApi.spec<br/>
/// Updated Dec 7, 2025 03:42:58
Class dc.musketeers.irisOasTestGenDemo.personApi.impl Extends %REST.Impl [ ProcedureBlock ]
{

Parameter ExposeServerExceptions = 1;

/// Create a new Person record<br/>
/// The method arguments hold values for:<br/>
///     person, Person object to be created<br/>
ClassMethod createPerson(person As %DynamicObject) As %DynamicObject
{
    Try {
        Set obj = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%New()
        Do obj.%JSONImport(person)
        $$$ThrowOnError(obj.%Save())
        
        Do ..%SetStatusCode(201)
        Do ..%SetHeader("Location","/dc/musketeers/irisOasTestGenDemo/personApi/"_obj.ID)
        $$$ThrowOnError(obj.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    } Catch ex {
        Do ..%SetStatusCode(400)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 400
        Set error.message = ex.DisplayString()
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
}

/// Retrieve a list of all Person records
ClassMethod listPeople() As %DynamicObject
{
    Try {
        Set result = []
        Set sql = "SELECT * FROM dc_musketeers_irisOasTestGenDemo_personApi.Person"
        Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
        While rs.%Next() {
            Set obj = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%OpenId(rs.ID)
            $$$ThrowOnError(obj.%JSONExportToStream(.json))
            Do result.%Push(##class(%DynamicObject).%FromJSON(json))
        }
        Do ..%SetStatusCode(200)
        Return result
    } Catch ex {
        Do ..%SetStatusCode(500)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 500
        Set error.message = ex.DisplayString()
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
}

/// Retrieve a single Person record by ID<br/>
/// The method arguments hold values for:<br/>
///     id, ID (OID) of the Person to operate on<br/>
ClassMethod getPersonById(id As %Integer) As %DynamicObject
{
    Try {
        Set obj = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%OpenId(id)
        If obj="" {
            Do ..%SetStatusCode(404)
            Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
            Set error.code = 404
            Set error.message = "Person not found"
            $$$ThrowOnError(error.%JSONExportToString(.json))
            Return ##class(%DynamicObject).%FromJSON(json)
        }

        // Export JSON string
        $$$ThrowOnError(obj.%JSONExportToString(.jsonString))
        Set dynObj = ##class(%DynamicObject).%FromJSON(jsonString)

        // --- Add headers ---
        // Generate a simple ETag (hash of JSON string)
        Set eTag = $System.Encryption.MD5Hash(jsonString)
        Set eTag = $SYSTEM.Encryption.Base64Encode(eTag)
        Do ..%SetHeader("ETag", eTag)

        // Add Cache-Control header (example: no-cache)
        Do ..%SetHeader("Cache-Control", "no-cache")

        // Set status code
        Do ..%SetStatusCode(200)

        Return dynObj
    } Catch ex {
        Do ..%SetStatusCode(500)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 500
        Set error.message = ex.DisplayString()
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
}

/// Update an existing Person record by ID<br/>
/// The method arguments hold values for:<br/>
///     id, ID (OID) of the Person to operate on<br/>
///     person, Updated Person object<br/>
ClassMethod updatePerson(id As %Integer, person As %DynamicObject) As %DynamicObject
{
    Set obj = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%OpenId(id)
    If obj="" {
        Do ..%SetStatusCode(404)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 404
        Set error.message = "Person not found"
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }

    // --- ID mismatch check ---
    If person.%Get("ID") '= id {
        Do ..%SetStatusCode(400)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 400
        Set error.message = "ID mismatch: path ID (" _ id _ ") does not match body ID (" _ person.%Get("ID") _ ")"
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }

    Try {
        Do obj.%JSONImport(person.%ToJSON())
        Do obj.%Save()
        Do ..%SetStatusCode(200)
        $$$ThrowOnError(obj.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    } Catch ex {
        Do ..%SetStatusCode(400)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 400
        Set error.message = ex.DisplayString()
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
}

/// Delete a Person record by ID<br/>
/// The method arguments hold values for:<br/>
///     id, ID (OID) of the Person to operate on<br/>
ClassMethod deletePerson(id As %Integer) As %Stream.Object
{
    Set obj = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Person).%OpenId(id)
    If obj="" {
        Do ..%SetStatusCode(404)
        #; Return {"code":404,"message":"Person not found"}
        Do ..%SetStatusCode(404)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 404
        Set error.message = "Person not found"
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
    Try {
        Do obj.%DeleteId(id)
        Do ..%SetStatusCode(204)
        Return ""
    } Catch ex {
        Do ..%SetStatusCode(500)
        Set error = ##class(dc.musketeers.irisOasTestGenDemo.personApi.Error).%New()
        Set error.code = 500
        Set error.message = ex.DisplayString()
        $$$ThrowOnError(error.%JSONExportToString(.json))
        Return ##class(%DynamicObject).%FromJSON(json)
    }
}

}
