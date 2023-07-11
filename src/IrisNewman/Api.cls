Class IrisNewman.Api Extends IrisNewman.ApiBase
{

Parameter htmlOutputFile As %String = "/opt/irisapp/testExecution.html";

Parameter collectionFile As %String = "/opt/irisapp/myCollection.json";

Parameter collectionRepoPath As %String = "/opt/irisapp/api-test";

// "/opt/irisapp/src/testCollectionExample.json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- Run tests -->
    <Route Url="/run_tests" Method="POST" Call="RunTestsJSON" Cors="true"/>
    <!-- Update Collection and run test -->
    <Route Url="/pull_and_run_tests" Method="GET" Call="PullRunTestsJSON" Cors="true"/>
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

    Set %response.Status=401
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
    
    //Set ruta = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)
    
    If archivo.LinkToFile(..#htmlOutputFile) {
        
        Do archivo.OutputToDevice()
        
    } Else {
        Write "No se pudo abrir el archivo."
    }

    
    Quit $$$OK
}

ClassMethod DownloadCollectionFromRepo(collectionRepoPath As %String, destinationFile As %String) [ Language = python ]
{
    import os
    import subprocess
    import shutil
    from configparser import ConfigParser

    config = ConfigParser()
    config.read('/opt/irisapp/bitbucket.cfg')
    
    bitbucket_username = config.get('repo', 'username')
    bitbucket_token_app = config.get('repo', 'apptoken')
    bitbucket_repository = config.get('repo', 'repository')
    bitbucket_collection_path = config.get('repo', 'collection_path')
    bitbucket_collection_path = bitbucket_collection_path.replace("'","")

    # Borramos carpeta del repositorio si existe
    try: 
        shutil.rmtree(collectionRepoPath)
    except:
        print('')    
        # no existe carpeta

    # URL del repositorio de Bitbucket
    repository_url = f'https://{bitbucket_username}:{bitbucket_token_app}@{bitbucket_repository}'
    

    # Comando para clonar el repositorio utilizando Git
    command = f'git clone {repository_url} {collectionRepoPath}'

    # Ejecutar el comando de clonación utilizando Git
    subprocess.call(command, shell=True)

    # Configurar COPY_BUFSIZE en un valor grande
    shutil.COPY_BUFSIZE = 1024 * 1024  # 1 MB

    # Copiar el archivo sobrescribiendo el destino si existe
    try:
        shutil.copy(bitbucket_collection_path, destinationFile) 
    except Exception as e:
        print(str(e))
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

ClassMethod PullRunTestsJSON() As %Status
{
  
    Do ..DownloadCollectionFromRepo(..#collectionRepoPath,..#collectionFile)
    
    try {

        Set source = %request.Content

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
