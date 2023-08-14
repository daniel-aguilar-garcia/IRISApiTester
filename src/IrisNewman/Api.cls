Class IrisNewman.Api Extends IrisNewman.ApiBase
{

Parameter htmlOutputFile As %String = "/opt/irisapp/testExecution.html";

Parameter collectionFile As %String = "/opt/irisapp/myCollection.json";

Parameter collectionRepoPath As %String = "/opt/irisapp/";

Parameter executionsTestsPath As %String = "/irisdev/app/src/Executions/";

// "/opt/irisapp/src/testCollectionExample.json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- Run tests -->
    <Route Url="/run_tests" Method="POST" Call="RunTestsJSON" Cors="true"/>

    <!-- Update Collection and run test -->
    <Route Url="/pull_and_run_tests" Method="GET" Call="PullRunTestsJSON" Cors="true"/>
    
    <!-- Update Collection run tests and return html file -->
    <Route Url="/pull_run_and_report" Method="GET" Call="PullRunReport" Cors="true"/>
    
    <!-- Update Collection run tests and return report file name -->
    <Route Url="/pull_run_and_file_json" Method="GET" Call="PullRunFileJson" Cors="true"/>

    <!-- Update Collection run tests and return report file name -->
    <Route Url="/pull_run_and_file" Method="GET" Call="PullRunFile" Cors="true"/>
    
    <!-- Show Report -->
    <Route Url="/show_report/:fileName" Method="GET" Call="ShowReport" Cors="true"/>
    
    <!-- example tests ok -->
    <Route Url="/test_ok" Method="GET" Call="TestOK" Cors="true"/>
    <!-- example tests ko -->
    <Route Url="/test_ko" Method="GET" Call="TestKO" Cors="true"/>

    </Routes>
}

ClassMethod ShowReport(fileName As %String = "") As %Status
{
    #Dim pathFile As %String
    Set %response.ContentType = "text/html"


    Set archivo = ##class(%Stream.FileCharacter).%New()
    
    //Set ruta = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)

    If (fileName '= "")
    {
        Set pathFile = ..#executionsTestsPath_fileName
    }Else{
        Set pathFile = ..#htmlOutputFile
    }
    
    
    If archivo.LinkToFile(pathFile) {
        
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

ClassMethod PullRunReport() As %Status
{
    #Dim outPutFile as %String;

    Do ..DownloadCollectionFromRepo(..#collectionRepoPath,..#collectionFile)
    
    try {

        Set source = %request.Content

        Set outPutFile = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)
        Do ..ShowReport(outPutFile)
 
        Set tSC=$$$OK
   
    
    } catch e {
        Set tSC=e.AsStatus()
        
    }
 
    Quit tSC
}

ClassMethod PullRunFile() As %Status
{
    #Dim outPutFile as %String;

    Set outPutFile = ""
    
    try {
        Do ..DownloadCollectionFromRepo(..#collectionRepoPath,..#collectionFile)

        Set source = %request.Content

        Set outPutFile = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)
        
        

        Set tSC=$$$OK
   
    
    } catch e {
        Set tSC=e.AsStatus()
        
    }
    
    Write outPutFile,!

    Quit tSC
}

ClassMethod PullRunFileJson() As %Status
{
    #Dim outPutFile as %String;

    Set objResponse = {}
    Set objResponse.file = ""

    
    
    try {
        Do ..DownloadCollectionFromRepo(..#collectionRepoPath,..#collectionFile)

        Set source = %request.Content

        Set objResponse.file = ..RunCollectionTest(..#collectionFile, ..#htmlOutputFile)
        
        

        Set tSC=$$$OK
   
    
    } catch e {
        Set tSC=e.AsStatus()
        
    }
    
    Write objResponse.%ToJSON(),!

    Quit tSC
}

ClassMethod RunCollectionTest(collectionFile As %String, htmlOutputFile As %String) As %String [ Language = python ]
{
        reportHistoricFileName = ''
        try:
            import subprocess
            import os
            import signal
            import shutil
            from datetime import datetime

            
            collection_file  = collectionFile
            html_output_file = htmlOutputFile
            
            command = f"newman run {collection_file} -r htmlextra --reporter-htmlextra-export {html_output_file} --reporter-htmlextra-title 'IRIS Api Tester'"
            
            process = subprocess.Popen(command, shell=True)

            process.wait()

            # Generar id único
            ahora = datetime.now()
            anio = str(ahora.year).zfill(4)
            mes = str(ahora.month).zfill(2)
            dia = str(ahora.day).zfill(2)
            hora = str(ahora.hour).zfill(2)
            minutos = str(ahora.minute).zfill(2)
            segundos = str(ahora.second).zfill(2)

            identificador = f"{anio}{mes}{dia}{hora}{minutos}{segundos}"
            reportHistoricFileName = f'{identificador}.html'
            reportHistoricPath = f'/irisdev/app/src/Executions/{reportHistoricFileName}'

            # Copiar el archivo sobrescribiendo el destino si existe
            shutil.copy(html_output_file, reportHistoricPath) 

            return reportHistoricFileName

           
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")
        except Exception as e:
            print(e)

        return reportHistoricFileName
}

}
