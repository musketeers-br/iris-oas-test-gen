Class dc.musketeers.irisOasTestGen.Main Extends %RegisteredObject
{

/// Application base directory
Property AppBaseDir As %String;

/// OpenAPI spec file
Property OpenapiSpec As %String;

/// Output directory
Property OutputDir As %String;

/// Package name for the generated client
Property PackageName As %String;

/// Custom template location
Property TemplateLocation As %String;

/// Used to execute external commands
Property Shell As SystemShell;

Method %OnNew(shell As SystemShell = {$$$NULLOREF}) As %Status
{
    If shell = $$$NULLOREF {
        Set shell = ##class(SystemShell).%New()
    }
    Set ..Shell = shell

    Set ..AppBaseDir = $System.Util.InstallDirectory()_"lib/iris-oas-test-gen"

    If ..OutputDir = "" {
        Set ..OutputDir = ..AppBaseDir _ "/generated-iris-client"
    }

    If ..PackageName = "" {
        Set ..PackageName = "mypackage"
    }
    
	Return $$$OK
}

/// Generate the OpenAPI client
Method Generate() As %Status
{
    Set sc = $$$OK

    Try {
        If ..OpenapiSpec = "" {
            Throw ##class(%Exception.General).%New("Property 'OpenapiSpec' cannot be empty.")
        }
        If ..OutputDir = "" {
            Throw ##class(%Exception.General).%New("Property 'OutputDir' cannot be empty.")
        }

        Set outFile = ##class(%Library.File).TempFilename(".irisoasgen.log")

        Set jarPath = ..AppBaseDir _ "/iris-object-script-openapi-generator-1.0.0.jar"
        Set cliJar = ..AppBaseDir _ "/openapi-generator-cli.jar"
        Set classPath = jarPath _ ":" _ cliJar
        Set outputDir = ..OutputDir

        Set program = "java"
        Set args = ""
        Set args($INCREMENT(args)) = "-cp"
        Set args($INCREMENT(args)) = classPath
        Set args($INCREMENT(args)) = "org.openapitools.codegen.OpenAPIGenerator"
        Set args($INCREMENT(args)) = "generate"
        Set args($INCREMENT(args)) = "-g"
        Set args($INCREMENT(args)) = "iris-object-script"
        Set args($INCREMENT(args)) = "-i"
        Set args($INCREMENT(args)) = ..OpenapiSpec
        Set args($INCREMENT(args)) = "-o"
        Set args($INCREMENT(args)) = outputDir
        // todo: atualizar testes unitários
        If ..PackageName '= "" {
            Set args($INCREMENT(args)) = "--additional-properties"
            Set args($INCREMENT(args)) = "x-musketeers-package-name=" _ ..PackageName
        }
        If ..TemplateLocation '= "" {
            Set args($INCREMENT(args)) = "-t"
            Set args($INCREMENT(args)) = ..TemplateLocation
        }
        Set flags = "/STDOUT="""_outFile_"""/STDERR="""_outFile_""""
        Set exitCode = ..Shell.Execute(flags, program, args...)

        // Throw an exception if the command failed
        If exitCode '= 0 {
            Set argsString = "["
            Set key = $ORDER(args(""))
            While key '= "" {
                Set argsString = argsString _ args(key) _ " "
                Set key = $ORDER(args(key))
            }
            Set argsString = $EXTRACT(argsString, 1, $LENGTH(argsString) - 1)_ "]"

            Throw ##class(%Exception.General).%New("Java command failed with exit code " _ exitCode _ ". Args: " _ argsString _ ". More information in file " _ outFile _ ".")
        }
    } Catch(ex) {
        Set sc = ex.AsStatus()
    }

    Return sc
}

/// <pre>
/// Execute the customized OpenAPI Generator.
/// This is a class method wrapper for the `Generate` instance method.
/// 
/// Parameters:
///    - openapiSpec (%String): Path to the OpenAPI specification file.
///    - outputDir (%String): [Optional] Directory to output the generated code. Defaults to &lt;install_dir&gt;/lib/iris-oas-test-gen/generated-iris-client.
///    - packageName (%String): [Optional] The package name for the generated classes. Defaults to 'mypackage'.
///    - templateLocation (%String): [Optional] Path to a directory with custom templates for the generator.
///    - main (Main): [Internal] An instance of the Main class, primarily for testing purposes.
/// 
/// Returns:
///    - %Status: The status of the generation process. Returns $$$OK on success.
/// </pre>
ClassMethod Run(openapiSpec As %String, outputDir As %String = "", packageName As %String = "", templateLocation As %String = "", main As Main = {$$$NULLOREF}) As %Status
{
    If main = $$$NULLOREF {
        Set main = ##class(Main).%New()
    }
    Set main.OpenapiSpec = $Get(openapiSpec)
    If outputDir '= "" {
        Set main.OutputDir = outputDir
    }
    If packageName '= "" {
        Set main.PackageName = packageName
    }
    Set main.TemplateLocation = templateLocation
    Return main.Generate()
}

/// <pre>
/// A convenience method that generates, cleans up, and loads the test classes into IRIS.
/// This method orchestrates the following steps:
/// 1. Cleans up previously generated files.
/// 2. Calls the `Run` method to generate the test classes from the OpenAPI specification.
/// 3. Displays the output log from the generator.
/// 4. Removes intermediate generator artifacts.
/// 5. Sets file permissions on the generated files.
/// 6. Imports the generated source code into the current IRIS namespace.
/// 
/// <b>Warning:</b> This method uses shell commands (`rm`, `cat`, `ls`, `head`, `chmod`) and is currently only compatible with Linux-like environments.
/// 
/// Parameters:
///    - openapiFile (%String): Path to the OpenAPI specification file.
///    - outputDir (%String): [Optional] Directory to output the generated code.
///    - packageName (%String): [Optional] The package name for the generated classes.
/// 
/// Returns:
///    - %Status: The status of the operation. Returns $$$OK on success.
/// </pre>
ClassMethod BuildAndDeploy(openapiFile As %String, outputDir As %String = "", packageName As %String = "") As %Status
{
    Set sc = $$$OK

    Try {
        // todo: it works only on linux like shells, adapt it to windows
        Set packageDir = $REPLACE(packageName, ".", "/")
        Set sourceFolder = "."

        // Clean up previous generations
        Do $ZF(-1, "rm -rf " _ outputDir _ "/" _ sourceFolder _"/" _ packageDir)

        // Run the generator
        $$$ThrowOnError(..Run(openapiFile, outputDir, packageName))

        // Delete non needed artifacts
        Do $ZF(-1, "rm -rf " _ outputDir _ "/.op*")

        // Enable writing for other users
        Do $ZF(-1, "chmod -R o+w " _ outputDir _ "/" _ sourceFolder _"/" _ packageDir)

        // Load the test files
        Do $SYSTEM.OBJ.Import(outputDir _ "/" _ sourceFolder _"/" _ packageDir)
    } Catch(ex) {
        Set sc = ex.AsStatus()
    }

    // Display the generator output
    Set tmpDir = "/" _ $PIECE(##class(%Library.File).TempFilename(), "/", 2)
    Set tmpFilePattern = tmpDir _ "/*.irisoasgen.log"
    Do $ZF(-1, "cat $(ls -t "_ tmpFilePattern _" | head -n 1)")

    Return sc
}

}
