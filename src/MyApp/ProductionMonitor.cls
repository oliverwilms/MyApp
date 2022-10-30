Class MyApp.ProductionMonitor
{

Query All(MyParm As %String) As %Query(CONTAINID = 1, ROWSPEC = "Title:%String,Author:%String")
{
}

Query AllPersons() As %Query(ROWSPEC = "ID:%String,Name:%String,DOB:%String,SSN:%String")
{
}

Query GetHostInfo() As %Query(ROWSPEC = "ID:%String,Name:%String")
{
}

/// Set pInfo(tConfigName) = $LB(tBusinessType,tClassName,tEnabled,tLastMessage)
Query GetItemInfo() As %Query(ROWSPEC = "ConfigName:%String,BusinessType:%String,ClassName:%String,Enabled:%String,LastMessage:%String")
{
}

Query ResponseReport(param As %String) As %Query(ROWSPEC = "")
{
}

ClassMethod AllPersonsExecute(ByRef qHandle As %Binary) As %Status
{
	Kill qHandle
	Set qHandle($I(qHandle)) = "^1^Oliver Tymo^02/28/1974^123-45-6789"
	Set qHandle = 0
	Quit $$$OK
}

ClassMethod AllPersonsFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AllPersonsExecute ]
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
	Set Row = $LB(tID,tName,tDOB,tSSN)
	Set AtEnd = 0
	Quit $$$OK
}

ClassMethod AllPersonsClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AllPersonsFetch ]
{
	Kill qHandle
	Set qHandle=""
	Quit $$$OK
}

ClassMethod GetHostInfoExecute(ByRef qHandle As %Binary) As %Status [ PublicList = pInfo ]
{
	Kill qHandle
	// Set pInfo(tBucket,tSort1,tSort2,tSort3) = $LB(tID,tName,tMsg,tLamp,tIcon,tCount,tCLamp,tCIcon,tCMsg,)
	Set tSC = ##class(User.ProductionMonitor).GetHostInfo(.pInfo)
	Set ary = "pInfo"
	Set queryary  =ary
	For {
		Set queryary = $QUERY(@queryary,1,data) 
		If (queryary = "") { Quit }
		Set qHandle($I(qHandle)) = data
	}
	Set qHandle = 0
	Quit $$$OK
}

ClassMethod GetHostInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetHostInfoExecute ]
{
	Set data = $Get(qHandle($I(qHandle)))
	If (data = "") {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set tID = $Piece(data,delim,2)
	Set tName = $Piece(data,delim,3)
	Set tDOB = $Piece(data,delim,4)
	Set tSSN = $Piece(data,delim,5)
	//Set Row = $lb(tID,tName,tDOB,tSSN)
	Set Row = data
	Set AtEnd = 0
	Quit $$$OK
}

ClassMethod GetHostInfoClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetHostInfoFetch ]
{
	Kill qHandle
	Set qHandle=""
	Quit $$$OK
}

ClassMethod GetItemInfoExecute(ByRef qHandle As %Binary) As %Status [ PublicList = pInfo ]
{
	Kill qHandle
	// Set pInfo(tConfigName) = $LB(tBusinessType,tClassName,tEnabled,tLastMessage)
	Set tSC = ##class(User.ProductionMonitor).GetItemInfo(.pInfo)
	Set tConfigName = ""
	For {
		Set tConfigName = $ORDER(pInfo(tConfigName),1,data) 
		If (tConfigName = "") { Quit }
		Set list = $LB(tConfigName)_data
		Set qHandle(tConfigName) = list
	}
	Set qHandle = ""
	Quit $$$OK
}

ClassMethod GetItemInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetItemInfoExecute ]
{
	Set data = ""
	Set tConfigName = $ORDER(qHandle(qHandle),1,data)
	If (tConfigName = "") {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set Row = data
	Set AtEnd = 0
	Set qHandle = tConfigName
	Quit $$$OK
}

ClassMethod GetItemInfoClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetItemInfoFetch ]
{
	Kill qHandle
	Set qHandle=""
	Quit $$$OK
}

ClassMethod ResponseReportExecute(ByRef qHandle As %Binary, param) As %Status
{
	Kill qHandle
	Set tSC = ##class(User.ResponseReport).GetData(param)
    Merge qHandle = ^TESTResponseReport
	Set qHandle = 0
	Quit $$$OK
}

ClassMethod ResponseReportFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AllPersonsExecute ]
{
	Set data = ""
	Set tServiceMsgHeaderId = $ORDER(qHandle(qHandle),1,data)
	If (tServiceMsgHeaderId = "") {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set Row = data
	Set AtEnd = 0
	Set qHandle = tServiceMsgHeaderId
	Quit $$$OK
}

ClassMethod ResponseReportClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AllPersonsFetch ]
{
	Kill qHandle
	Set qHandle=""
	Quit $$$OK
}

}