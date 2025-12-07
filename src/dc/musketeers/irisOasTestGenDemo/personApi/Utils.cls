Class dc.musketeers.irisOasTestGenDemo.personApi.Utils Extends %RegisteredObject
{

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

ClassMethod RunTests()
{
    Set tmpGbl = "^UnitTestRoot.backup"
    Lock +(@tmpGbl)
    Merge @tmpGbl = ^UnitTestRoot
    Try {
        Set ^UnitTestRoot = "/home/irisowner/dev"
        Set sourceFolder = "."
        Set srcDir = "/tests/" _ sourceFolder _"/dc/musketeers/irisOasTestGenDemo/personApi"
        #; Set srcDir = "/tests/sample/personapi"
        $$$ThrowOnError($SYSTEM.OBJ.Import(^UnitTestRoot _ srcDir, "ck"))
        $$$ThrowOnError(##class(%UnitTest.Manager).RunTest(srcDir, "/nodelete"))
    } Catch (ex) {
        ZW ex
    }
    Merge ^UnitTestRoot = @tmpGbl
    Lock -(@tmpGbl)
}

/// Convenience method to generate tests for the Person API
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
