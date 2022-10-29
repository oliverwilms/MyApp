Class MyApp.ProductionMonitor
{

Query All(MyParm As %String) As %Query(CONTAINID = 1, ROWSPEC = "Title:%String,Author:%String")
{
}

Query AllPersons() As %Query(ROWSPEC = "ID:%String,Name:%String,DOB:%String,SSN:%String")
{
}

ClassMethod AllPersonsExecute(ByRef qHandle As %Binary) As %Status
{
	Kill qHandle
	Set qHandle($I(qHandle)) = "^1^Oliver Tymo^02/28/1974^123-45-6789"
	Set qHandle = 0
	Quit $$$OK
}

ClassMethod AllPersonsFetch(
	ByRef qHandle As %Binary,
	ByRef Row As %List,
	ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AllPersonsExecute ]
{
	Set data = $Get(qHandle($I(qHandle)))
	Set delim = $Extract(data,1)
	If (delim = "") {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set tID = $Piece(data,delim,2)
	Set tName = $Piece(data,delim,3)
	Set tDOB = $Piece(data,delim,4)
	Set tSSN = $Piece(data,delim,5)
	Set Row = $lb(tID,tName,tDOB,tSSN)
	Set AtEnd = 0
	Quit $$$OK
}

ClassMethod AllPersonsClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AllPersonsFetch ]
{
	Kill qHandle
	Set qHandle=""
	Quit $$$OK
}

}
