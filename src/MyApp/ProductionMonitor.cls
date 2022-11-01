Class MyApp.ProductionMonitor
{

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

/// Set list = $LB(tRequestMsgHeaderId,tRequestMsgBodyId,tRequestMsgClassName,tRequestTimeCreated,tSessionId,tResponseMsgHeaderId)
Query ResponseReport(pName As %String, pFrom As %String, pTill As %String) As %Query(ROWSPEC = "Session:%String,SvcMsgHdr:%String,ServiceTimeCreated:%String,PrcMsgHdr:%String,URL:%String,Response:%String")
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

ClassMethod ResponseReportExecute(ByRef qHandle As %Binary, pName, pFrom, pTill) As %Status
{
	Set ^TEST($I(^TEST))="ResponseReportExecute"
	Kill qHandle
	Set pName = $Get(pName)
	Set pFrom = $Get(pFrom)
	Set pTill = $Get(pTill)
	Set tSC = ##class(User.ResponseReport).GetData(pName,pFrom,pTill)
    Merge qHandle = ^TESTResponseReport
	Set qHandle = 0
	Quit $$$OK
}

ClassMethod ResponseReportFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AllPersonsExecute ]
{
	Set ^TEST($I(^TEST))="ResponseReportFetch"
	Set data = ""
	Set tRequestMsgHeaderId = $ORDER(qHandle(qHandle),1,data)
	If (tRequestMsgHeaderId = "") {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	/// Set list = $LB(tRequestMsgHeaderId,tRequestMsgBodyId,tRequestMsgClassName,tRequestTimeCreated,tSessionId,tResponseMsgHeaderId,tTargetBusinessType)
	Set tRequestMsgBodyId = $LIST(data,2)
	Set tRequestMsgClassName = $LIST(data,3)
	Set tRequestTimeCreated = $LIST(data,4)
	Set tSessionId = $LIST(data,5)
	//Set tProcessName = $LIST(data,6)
	//Set tProcessTarget = tProcessName
	Set tRespHeaderId = $Piece(data,"^",6)
	//Set tTargetBusinessType = $LIST(data,7)
	/*
	Set tData = ##class(User.ResponseReport).GetMsgData(tSessionId,tProcessName,tRequestMsgHeaderId)
	Set tProcessMsgHeaderId = $Piece(tData,"^",2)
	Set tProcessTimeCreated = $Piece(tData,"^",3)
	Set tProcessTimeProcessed = $Piece(tData,"^",4)
	Set tProcessTarget = $Piece(tData,"^",5)
	Set tRespHeaderId = $Piece(tData,"^",6)
	*/
	Set tProcessTarget = ""
	Set tData = ##class(User.ResponseReport).GetRespData(tSessionId,tProcessTarget,tRespHeaderId)
	Set tResponseMsgBodyId = $Piece(tData,"^",2)
	Set tResponseTimeCreated = $Piece(tData,"^",3)
	Set tURLString = ##class(User.ResponseReport).GetMsgBodyURL(tRequestMsgClassName,tRequestMsgBodyId)
	Set tResponseStatusLine = ##class(User.ResponseReport).GetMsgBodyStatusLine(tRequestMsgClassName,tResponseMsgBodyId)
	Set list = $LB(tSessionId,tRequestMsgHeaderId,tRequestTimeCreated,tProcessMsgHeaderId,tURLString,tResponseStatusLine)
	Set Row = list
	Set AtEnd = 0
	Set qHandle = tRequestMsgHeaderId
	Quit $$$OK
}

ClassMethod ResponseReportClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AllPersonsFetch ]
{
	Set ^TEST($I(^TEST))="ResponseReportClose"
	Kill qHandle
	Set qHandle=""
	Kill ^TESTResponseReport
	Quit $$$OK
}

}
