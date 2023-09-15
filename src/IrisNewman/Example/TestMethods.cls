Class IrisNewman.Example.TestMethods Extends IrisNewman.Example.TestBase
{

ClassMethod TestOK() As %Status
{
    Set testNumber = 1
    Set a = 1
    Set b = 2

    Set res = ..SumNumbers(a,b)

    Do ..assert(res,3,$G(%methodname),testNumber)

    Quit $$$OK
}

ClassMethod SumNumbers(numberA As %Integer, numberB As %Integer) As %Integer
{
    Return numberA + numberB
}

ClassMethod TestKO() As %Status
{
    Set testNumber = 1
    Set a=1
    Set b=0
    Set res=..SumNumbers(a,b)
    
    
    Do ..assert(res,3,$G(%methodname),testNumber)
        
    
    Quit $$$OK
}

ClassMethod TestAssert()
{
    Set testNumber = 0

    Do ..assert("hello","hello",$G(%methodname),.testNumber)

    Quit $$$OK
}

ClassMethod TestAssertKO()
{
    Set testNumber = 1

    Do ..assert("hello","bye",$G(%methodname),.testNumber)

    Quit $$$OK
}

ClassMethod InsertPerson()
{
    Set testNumber = 1
    Set method=$G(%methodname)

    TSTART
    
    Set person=##class(IrisNewman.Example.Entity.Person).%New()
    Set person.IDCard="11111111H"
    Set person.Name="Incognito Guy"
    Set person.Address="False Street, 123"
    Set person.City="Springfield"
    Set res = person.%Save()

    Do ..assert(res,1)

    Set personReaded = ##class(IrisNewman.Example.Entity.Person).%OpenId(person.IDCard)

    Do ..assert(personReaded.Name,"Incognito Guy",method,testNumber)
    
    TROLLBACK

    Quit $$$OK
}

ClassMethod DeletePerson()
{
    Set testNumber = 1
    Set method=$get(%methodname)

    TSTART
    Set persons=##class(%ListOfDataTypes).%New()
    Do ##class(IrisNewman.Example.Entity.Person).Populate(1,0,1,.persons)
    
    Set objPerson=persons(1)
    Set res=objPerson.%Save()
    
    Do ..assert(res,1,method,testNumber)


    Set id = objPerson.IDCard
    
    Do ..assertNotEqual(id,"",method,testNumber)

    Set res=##class(IrisNewman.Example.Entity.Person).%DeleteId(id)
    
    Do ..assert(res,1,method,testNumber)

    


   TROLLBACK

    Quit $$$OK
}

}
