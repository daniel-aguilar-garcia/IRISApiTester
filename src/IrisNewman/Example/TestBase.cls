Class IrisNewman.Example.TestBase [ Abstract ]
{

ClassMethod assert(%value1, %value2, method, testNumber)
{
        Set x=$INCREMENT(testNumber)
        If (%value1'=%value2)
        {
            SET throwException = ##class(%Exception.General).%New("Test "_testNumber_": Method "_method_" in class "_$CLASSNAME()_" FAILED, expected: "_%value2_" recieved: "_%value1)
            THROW throwException
        }
}

ClassMethod assertNotEqual(%value1, %value2, method, testNumber)
{
        Set x=$INCREMENT(testNumber)
        If (%value1=%value2)
        {
            SET throwException = ##class(%Exception.General).%New("Test "_testNumber_": Method "_method_" in class "_$CLASSNAME()_" FAILED, expected: "_%value2_" recieved: "_%value1)
            THROW throwException
        }
}

}
