Class dc.musketeers.irisOasTestGen.service.API Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/generate-upload" Method="POST" Call="GenerateFromUpload"/>
</Routes>
}

ClassMethod GenerateFromUpload() As %Status
{
    Set %response.ContentType = "application/json"
    Set result = {}
    Set tempFile = ""
    
    Try {
        Set content = %request.Content
        If '$IsObject(content) Set content = {}.%FromJSON(content)
        
        Set base64Data = content.base64
        Set remoteTempDir = content.remoteTempDir
        Set outputDir = content.outputDir
        
        If (base64Data = "") || (remoteTempDir = "") || (outputDir = "") {
            Set result.status = "error"
            Set result.message = "Required parameters are missing: base64, remoteTempDir, or outputDir."
            Write result.%ToJSON()
            Return $$$OK
        }

        If '##class(%Library.File).DirectoryExists(remoteTempDir) {
            Set created = ##class(%Library.File).CreateDirectoryChain(remoteTempDir)
            If 'created {
                Throw ##class(%Exception.General).%New("Could not create the temporary directory: "_remoteTempDir)
            }
        }

        Set tempFileName = "openapi_"_$Random(100000)_".json"
        Set tempFile = ##class(%Library.File).NormalizeFilename(tempFileName, remoteTempDir)
        
        Set fileStream = ##class(%Stream.FileCharacter).%New()
        Do fileStream.LinkToFile(tempFile)
        
        Set decoded = $System.Encryption.Base64Decode(base64Data)
        Do fileStream.Write(decoded)
        Do fileStream.%Save()
        
        Set sc = ##class(dc.musketeers.irisOasTestGen.Main).Run(tempFile, outputDir)
        
        If $$$ISOK(sc) {
            Set result.status = "success"
            Set result.message = "Generated at "_outputDir
        } Else {
            Set result.status = "error"
            Set result.message = $System.Status.GetErrorText(sc)
        }

    } Catch ex {
        Set result.status = "error"
        Set result.message = "Exception: " _ ex.DisplayString()
    }

    If (tempFile '= "") && (##class(%Library.File).Exists(tempFile)) {
        Do ##class(%Library.File).Delete(tempFile)
    }
    
    Write result.%ToJSON()
    Return $$$OK
}

}
