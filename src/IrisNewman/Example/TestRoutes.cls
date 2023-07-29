Class IrisNewman.Example.TestRoutes Extends IrisNewman.ApiBase
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- Run the test -->
    <Route Url="/:class/:method" Method="GET" Call="ExecuteTest" Cors="true"/>
    
</Routes>
}

ClassMethod ExecuteTest(class As %String, method As %String)
{
   
    try{

        Set resultado = $classmethod(class, method)
         If resultado = $$$NULLOREF {
            Write "El método '"_method_"' no existe en la clase "_class_".", !
        }

    }catch(e)
    {
        Set throwException = ##class(%Exception.General).%New(e.DisplayString(1))
        THROW throwException
    }


    Quit resultado
}

}
