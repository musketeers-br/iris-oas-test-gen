Class dc.musketeers.irisOasTestGen.unittests.TestMain Extends %UnitTest.TestCase
{

/// Test the %OnNew constructor, ensuring properties are set correctly.
Method TestOnNew()
{
    #dim shell As MockShell
    Set shell = ##class(MockShell).%New()
    
    #dim main As dc.musketeers.irisOasTestGen.Main
    Set main = ##class(dc.musketeers.irisOasTestGen.Main).%New(shell)
	Set expectedDir = $System.Util.InstallDirectory()_"lib/iris-oas-test-gen"
    
    Do $$$AssertTrue(main.AppBaseDir [ "lib/iris-oas-test-gen", "AppBaseDir should contain base path" )
    Do $$$AssertEquals(main.Shell, shell, "Shell property should be the provided mock object")
	Do $$$AssertEquals(expectedDir, main.AppBaseDir, "AppBaseDir property must be set in %OnNew")
    Do $$$AssertEquals(main.OutputDir, expectedDir _ "/generated-iris-client", "OutputDir should have a default value")
}

}
