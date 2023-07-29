Class IrisNewman.Example.Entity.Person Extends (%Persistent, %JSON.Adaptor, %Populate)
{

Property IDCard As %String(POPSPEC = "SSN()");

Property Name As %String(POPSPEC = "Name()");

Property Address As %String(POPSPEC = "Street()");

Property City As %String(POPSPEC = "City()");

Index Index On IDCard [ IdKey ];

ClassMethod AddTestData(amount As %Integer = 10)
{
    d ..Populate(amount)
}

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Address</Value>
</Value>
<Value name="4">
<Value>City</Value>
</Value>
</Data>
<DataLocation>^IrisNewman.ExampleB9EA.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<IdLocation>^IrisNewman.ExampleB9EA.PersonD</IdLocation>
<IndexLocation>^IrisNewman.ExampleB9EA.PersonI</IndexLocation>
<StreamLocation>^IrisNewman.ExampleB9EA.PersonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
