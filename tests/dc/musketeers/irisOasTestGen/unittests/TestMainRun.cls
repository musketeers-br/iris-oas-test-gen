Class dc.musketeers.irisOasTestGen.unittests.TestMainRun Extends %UnitTest.TestCase
{

Parameter OpenAPISpecPath = "/mock/path/to/spec.yaml";

Parameter TemplatePath = "/mock/path/to/custom/template";

/// Test the Run method when the OpenAPI specification is empty, expecting an error.
Method TestRunEmptySpec()
{
    // No need for a mock shell or main object here, as the failure happens during validation inside Generate.
    Set sc = ##class(dc.musketeers.irisOasTestGen.Main).Run("")
    
    Do $$$AssertStatusNotOK(sc, "Run should fail when OpenapiSpec is empty")
    
    Set errorMessage = $System.Status.GetErrorText(sc)
    Do $$$AssertTrue(errorMessage [ "Property 'OpenapiSpec' cannot be empty.", "Error message should show the validation failure." )
}

/// Test the Run method for a successful execution without a custom template.
Method TestRunSuccess()
{
    #dim mockShell As MockShell
    Set mockShell = ##class(MockShell).%New()
    Set mockShell.ExecuteExitCode = 0 // Simulate successful external call
    
    #dim mockMain As dc.musketeers.irisOasTestGen.Main
    // Initialize a Main object with the MockShell
    Set mockMain = ##class(dc.musketeers.irisOasTestGen.Main).%New(mockShell)

    Set sc = ##class(dc.musketeers.irisOasTestGen.Main).Run(
        ..#OpenAPISpecPath, // openapiSpec (Referencing parameter with ..#)
        "", // outputDir (empty)
        "", // templateLocation (empty)
        mockMain // main (injected mock)
    )
    
    Do $$$AssertStatusOK(sc, "Run should succeed when the underlying Generate call is successful.")
    Do $$$AssertEquals(mockMain.OpenapiSpec, ..#OpenAPISpecPath, "OpenapiSpec property should be set correctly.")
    Do $$$AssertNotEquals(mockMain.OutputDir, "", "OutputDir should have its default value when not provided to Run.")
    Do $$$AssertEquals(mockMain.TemplateLocation, "", "TemplateLocation property should be empty.")
    Do $$$AssertEquals(mockShell.ExecuteCallCount, 1, "The Execute method should be called exactly once.")
    Do $$$AssertNotTrue(mockShell.ExecuteArgs [ " -t", "The -t (template) flag should NOT be present." )
}

/// Test the Run method for a successful execution with a custom template.
Method TestRunWithTemplate()
{
    #dim mockShell As MockShell
    Set mockShell = ##class(MockShell).%New()
    Set mockShell.ExecuteExitCode = 0 
    
    #dim mockMain As dc.musketeers.irisOasTestGen.Main
    Set mockMain = ##class(dc.musketeers.irisOasTestGen.Main).%New(mockShell)

    Set sc = ##class(dc.musketeers.irisOasTestGen.Main).Run(
        ..#OpenAPISpecPath, 
        "", // outputDir (empty)
        ..#TemplatePath, // templateLocation (set)
        mockMain 
    )
    
    Do $$$AssertStatusOK(sc, "Run should succeed when using a custom template.")
    Do $$$AssertEquals(mockMain.TemplateLocation, ..#TemplatePath, "TemplateLocation property should be set correctly.")
    Do $$$AssertNotEquals(mockMain.OutputDir, "", "OutputDir should have its default value when not provided to Run.")
    
    // Assert that the command arguments contain the template flag and path
    Do $$$AssertTrue(mockShell.ExecuteArgs [ (" -t "_..#TemplatePath), "The -t (template) flag and path should be present in arguments." )
}

/// Test the Run method when the external command fails (exitCode != 0).
Method TestRunCommandFailure()
{
    #dim mockShell As MockShell
    Set mockShell = ##class(MockShell).%New()
    Set mockShell.ExecuteExitCode = 1 // Simulate failure from Java command
    
    #dim mockMain As dc.musketeers.irisOasTestGen.Main
    Set mockMain = ##class(dc.musketeers.irisOasTestGen.Main).%New(mockShell)

    Set sc = ##class(dc.musketeers.irisOasTestGen.Main).Run(
        ..#OpenAPISpecPath, 
        "",
        ..#TemplatePath, 
        mockMain 
    )
    
    Do $$$AssertStatusNotOK(sc, "Run should fail when the Java command execution fails.")
    
    Set errorMessage = $System.Status.GetErrorText(sc)
    Do $$$AssertTrue(errorMessage [ "Java command failed with exit code 1", "Error message should report the command failure." )
}

}
