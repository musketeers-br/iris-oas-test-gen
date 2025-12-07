Class dc.musketeers.irisOasTestGenDemo.personApi.Person Extends (%Persistent, %JSON.Adaptor)
{

/// Calculated property for ID inclusion in JSON exporting.
Property ID As %BigInt(%JSONINCLUDE = "OUTPUTONLY") [ Calculated, SqlComputeCode = { set {*} = {%%ID} }, SqlComputed ];

Property Name As %String [ Required ];

Property Title As %String;

Property Company As %String;

Property Phone As %String;

Property DOB As %Date;

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ID</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Title</Value>
</Value>
<Value name="5">
<Value>Company</Value>
</Value>
<Value name="6">
<Value>Phone</Value>
</Value>
<Value name="7">
<Value>DOB</Value>
</Value>
</Data>
<DataLocation>^dc.musketeers.irisO59DB.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<IdLocation>^dc.musketeers.irisO59DB.PersonD</IdLocation>
<IndexLocation>^dc.musketeers.irisO59DB.PersonI</IndexLocation>
<StreamLocation>^dc.musketeers.irisO59DB.PersonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
