Class dc.musketeers.irisOasTestGen.unittests.TestMainGenerate Extends %UnitTest.TestCase
{

Parameter OpenAPISpecPath = "/mock/path/to/spec.yaml";

Parameter TemplatePath = "/mock/path/to/custom/template";

/// Test Generate method when OpenapiSpec is empty, expecting an error.
Method TestGenerateEmptySpec()
{
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New()
    Set main.OutputDir = "/some/existing/dir" // Set a dummy value to isolate the spec test
    // OpenapiSpec is "" by default
    
    Set sc = main.Generate()
    
    Do $$$AssertStatusNotOK(sc, "Generate should fail when OpenapiSpec is empty")
    Do $$$AssertTrue($System.Status.GetErrorText(sc) [ "Property 'OpenapiSpec' cannot be empty.", "Error message should mention empty spec" )
}

/// Test Generate method when OutputDir is empty, expecting an error.
Method TestGenerateEmptyOutputDir()
{
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New()
    Set main.OpenapiSpec = ..#OpenAPISpecPath
    Set main.OutputDir = ""
    
    Set sc = main.Generate()
    
    Do $$$AssertStatusNotOK(sc, "Generate should fail when OutputDir is empty")
    Do $$$AssertTrue($System.Status.GetErrorText(sc) [ "Property 'OutputDir' cannot be empty.", "Error message should mention empty OutputDir" )
}

/// Test Generate method success case with no custom template.
Method TestGenerateSuccess()
{
    #dim shell As MockShell
    Set shell = ##class(MockShell).%New()
    Set shell.ExecuteExitCode = 0 // Simulate success
    
    #dim main As dc.musketeers.irisOasTestGen.Main
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New(shell)
    Set main.OpenapiSpec = ..#OpenAPISpecPath
    Set main.TemplateLocation = "" // No template

    Set sc = main.Generate()
    
    Do $$$AssertStatusOK(sc, "Generate should succeed when Java command returns 0")
    Do $$$AssertEquals(shell.ExecuteCallCount, 1, "Shell Execute should be called once")
    Do $$$AssertEquals(shell.ExecuteProgram, "java", "Program should be 'java'")
    
    // Check core arguments, excluding temporary file name
    Do $$$AssertTrue(shell.ExecuteArgs [ " -i "_..#OpenAPISpecPath, "Args should contain input file spec" )
    Do $$$AssertTrue(shell.ExecuteArgs [ " -g iris-object-script", "Args should contain generator ID" )
    Do $$$AssertTrue(shell.ExecuteArgs [ " org.openapitools.codegen.OpenAPIGenerator generate", "Args Do should contain class and command" )
    Do $$$AssertTrue(shell.ExecuteArgs [ " -cp", "Args should contain classpath flag" )
    
    // Ensure template arguments are ABSENT
    Do $$$AssertNotTrue(shell.ExecuteArgs [ " -t", "Args should NOT contain template flag" )
}

/// Test Generate method success case WITH a custom template.
Method TestGenerateWithTemplate()
{
    #dim shell As MockShell
    Set shell = ##class(MockShell).%New()
    Set shell.ExecuteExitCode = 0 // Simulate success
    
    #dim main As dc.musketeers.irisOasTestGen.Main
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New(shell)
    Set main.OpenapiSpec = ..#OpenAPISpecPath
    Set main.TemplateLocation = ..#TemplatePath // Template location set

    Set sc = main.Generate()
    
    Do $$$AssertStatusOK(sc, "Generate should succeed when Java command returns 0")
    
    // Ensure template arguments ARE PRESENT
    Do $$$AssertTrue(shell.ExecuteArgs [ " -t "_..#TemplatePath, "Args should contain template flag and path" )
}

/// Test Generate method when the external command fails (exitCode != 0).
Method TestGenerateCommandFailure()
{
    #dim shell As MockShell
    Set shell = ##class(MockShell).%New()
    Set shell.ExecuteExitCode = 1 // Simulate failure
    
    #dim main As dc.musketeers.irisOasTestGen.Main
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New(shell)
    Set main.OpenapiSpec = ..#OpenAPISpecPath
    Set main.TemplateLocation = ..#TemplatePath

    Set sc = main.Generate()
    
    Do $$$AssertStatusNotOK(sc, "Generate should fail when Java command returns non-zero exit code")
    
    // Check for specific error message content
    Set errorMessage = $System.Status.GetErrorText(sc)
    Do $$$AssertTrue(errorMessage [ "Java command failed with exit code 1", "Error message should contain exit code 1" )
    Do $$$AssertTrue(errorMessage [ "Args:", "Error message should contain the Args list" )
}

}
