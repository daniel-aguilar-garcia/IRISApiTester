Class IrisNewman.Api Extends IrisNewman.ApiBase
{

Parameter htmlOutputFile As %String = "/opt/irisapp/testExecution.html";

Parameter collectionFile As %String = "/opt/irisapp/myCollection.json";

Parameter collectionRepoPath As %String = "/opt/irisapp/";

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
    config.read('/opt/irisapp/repository.cfg')
    
    platform = config.get('repo', 'platform').replace("'","")
    
    username = config.get('repo', 'username')
    token_app = config.get('repo', 'apptoken')
    repository = config.get('repo', 'repository')
    collection_path = config.get('repo', 'collection_path')
    repository_name = config.get('repo', 'repository_name')
    repository_name = repository_name.replace("'","")
    collection_path = collection_path.replace("'","")
    collection_full_path = collectionRepoPath + repository_name + '/' + collection_path
    collectionRepoPath = collectionRepoPath + repository_name

    # Borramos carpeta del repositorio si existe
    try: 
        shutil.rmtree(collectionRepoPath)
    except:
        print('')    
        # no existe carpeta
    
    if (platform == 'github'):
        # URL del repositorio de github
        if (username == "''"):
            repository_url = repository.replace("'","")
        else:
            repository_url = f'https://{username}:{token_app}@github.com/{username}/{repository_name}.git'
    elif (platform == 'bitbucket'):
        # URL del repositorio de Bitbucket
        repository_url = f'https://{username}:{token_app}@{repository}'
    else:
        raise Exception("Platform not supported")


    # Comando para clonar el repositorio utilizando Git
    command = f'git clone {repository_url} {collectionRepoPath}'

    # Ejecutar el comando de clonación utilizando Git
    subprocess.call(command, shell=True)

    # Configurar COPY_BUFSIZE en un valor grande
    shutil.COPY_BUFSIZE = 1024 * 1024  # 1 MB

    # Copiar el archivo sobrescribiendo el destino si existe
    try:
        shutil.copy(collection_full_path, destinationFile) 
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
