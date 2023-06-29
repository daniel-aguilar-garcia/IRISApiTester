Class IrisNewman.Api Extends IrisNewman.ApiBase
{

Parameter htmlOutputFile As %String = "/opt/irisapp/testExecution.html";

Parameter collectionFile As %String = "/opt/irisapp/myCollection.json";

// "/opt/irisapp/src/testCollectionExample.json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- Run tests -->
    <Route Url="/run_tests" Method="POST" Call="RunTestsJSON" Cors="true"/>
    <!-- Show Report -->
    <Route Url="/show_report" Method="GET" Call="ShowReport" Cors="true"/>
    <!-- example tests ok -->
    <Route Url="/test_ok" Method="GET" Call="TestOK" Cors="true"/>
    <!-- example tests ko -->
    <Route Url="/test_ko" Method="GET" Call="TestKO" Cors="true"/>

    </Routes>
}

ClassMethod TestOK() As %Status
{
    Quit $$$OK
}

ClassMethod TestKO() As %Status
{

    Set %response.Status=500
    Set message = ""
    Set a=1
    Set b=0
    
    
    try{
        Set x= a / b
        Write x
    }catch(e)
    {
        Set message = e.DisplayString(1)
    }


    Quit $$$ERROR(5001,message)
}

ClassMethod ShowReport() As %Status
{
    Set %response.ContentType = "text/html"


    Set archivo = ##class(%Stream.FileCharacter).%New()
    
    Set ruta = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)
    
    If archivo.LinkToFile(ruta) {
        
        Do archivo.OutputToDevice()
        
    } Else {
        Write "No se pudo abrir el archivo."
    }

    
    Quit $$$OK
}

ClassMethod RunTestsJSON() As %Status
{
  
    Set filePath = ..#collectionFile 
    
    try {

        Set source = %request.Content

        set file=##class(%File).%New(filePath)
        do file.Open("WSN")
        
        Do source.%ToJSON(.file)
        
        Do file.%Save()
        
        Do ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)

        Do ..ShowReport()
 
        Set tSC=$$$OK
   
    
    } catch e {
        Set tSC=e.AsStatus()
        
    }
 
    Quit tSC
}

ClassMethod RunCollectionTest(collectionFile As %String, htmlOutputFile As %String) As %String [ Language = python ]
{
        try:
            import subprocess
            import os
            import signal

            
            collection_file  = collectionFile
            html_output_file = htmlOutputFile
            
            command = f"newman run {collection_file} -r htmlextra --reporter-htmlextra-export {html_output_file} --reporter-htmlextra-title 'IRIS Api Tester'"
            
            process = subprocess.Popen(command, shell=True)

            process.wait()

            return html_output_file

           
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")
        except Exception as e:
            print(e)

        return ''
}

}
