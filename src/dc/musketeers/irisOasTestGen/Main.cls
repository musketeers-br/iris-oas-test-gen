Class dc.musketeers.irisOasTestGen.Main Extends %RegisteredObject
{

/// Application base directory
Property AppBaseDir As %String;

/// OpenAPI spec file
Property OpenapiSpec As %String;

/// Output directory
Property OutputDir As %String;

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

        Set outFile = ##class(%Library.File).TempFilename()

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
        If ..TemplateLocation '= "" {
            Set args($INCREMENT(args)) = "-t"
            Set args($INCREMENT(args)) = ..TemplateLocation
        }
        Set flags = "/STDOUT="""_outFile_"""/STDERR="""_outFile_""""
        #; Set flags = ""
        #; Set exitCode = $ZF(-100, flags, program, args...)
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

/// Execute the customized OpenAPI Generator
ClassMethod Run(openapiSpec As %String, outputDir As %String = "", templateLocation As %String = "", main As Main = {$$$NULLOREF}) As %Status
{
    If main = $$$NULLOREF {
        Set main = ##class(Main).%New()
    }
    Set main.OpenapiSpec = $Get(openapiSpec)
    If outputDir '= "" {
        Set main.OutputDir = outputDir
    }
    Set main.TemplateLocation = templateLocation
    Return main.Generate()
}

}
