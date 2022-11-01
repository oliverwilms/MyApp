Class User.ResponseReport
{

ClassMethod GetData(
	pName As %String,
	pFrom As %String,
	pTill As %String) As %Status
{
	Set ^TEST($I(^TEST))="GetData"
	Kill ^TESTResponseReport
	Set tSC = $$$OK
	Set tBegin = $Get(pFrom)
	Set tEnd = $Get(pTill)
	If (tBegin = "") { Set tBegin = "2022-04-28 14:00:00" }
	If (tEnd = "") { Set tEnd = "2099-12-31 23:59:59" }
	//If ($Get(pServiceName) = "") { Set pServiceName = "IncomingFSC" }
	/*
	Set tSQL = ""
	Set tSQL($I(tSQL)) = "SELECT ID, Banked, BusinessProcessId, CorrespondingMessageId, Description, ErrorStatus, Invocation, "
	Set tSQL($I(tSQL)) = "IsError, MessageBodyClassName, MessageBodyId, Priority, Resent, ReturnQueueName, SessionId, "
	Set tSQL($I(tSQL)) = "SourceBusinessType, SourceConfigName, Status, SuperSession, TargetBusinessType, TargetConfigName, "
	Set tSQL($I(tSQL)) = "TargetQueueName, TimeCreated, TimeProcessed, Type FROM Ens.MessageHeader "
	Set tSQL($I(tSQL)) = "WHERE TimeCreated BETWEEN '"_tBegin_"' AND '"_tEnd_"'"
	Set tSQL($I(tSQL)) = " AND SourceConfigName = 'IncomingFSC'"
	*/
	Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated FROM Ens.MessageHeader"
	//Set tWhere = " WHERE TimeCreated BETWEEN '"_tBegin_"' AND '"_tEnd_"' AND SourceConfigName = 'IncomingFSC'"
	Set tWhere = " WHERE TargetBusinessType = 3 AND TimeCreated BETWEEN ? AND ?"
	If ($Get(pName) '= "") Set tWhere = tWhere_" AND SourceConfigName = ?"
	Set tOrderBy = " ORDER BY ID DESC"
	//ZW tQuery
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 1  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery_$Get(tWhere)_$Get(tOrderBy))
	Set ^TEST($I(^TEST)) = qStatus
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
	#Dim rset As %SQL.StatementResult
	If ($Get(pName) = "") { Set rset = tStatement.%Execute(tBegin,tEnd) }
	If ($Get(pName) '= "") { Set rset = tStatement.%Execute(tBegin,tEnd,pName) }
	Set x = rset.%SQLCODE
	Set ^TEST($I(^TEST)) = x
	While rset.%Next(.tSC) {
		Set tRequestMsgHeaderId = rset.%Get("ID")
		Set tResponseMsgHeaderId = rset.%Get("CorrespondingMessageId")
		Set tRequestMsgBodyId = rset.%Get("MessageBodyId")
		Set tRequestMsgClassName = rset.%Get("MessageBodyClassName")
		Set tRequestTimeCreated = rset.%Get("TimeCreated")
		Set tSessionId = rset.%Get("SessionId")
		//Set tTargetBusinessType = rset.%Get("TargetBusinessType")
		//Set ^TEST($I(^TEST)) = "TargetType = "_tTargetBusinessType
		//Set tProcessName = rset.%Get("TargetConfigName")
		Set list = $LB(tRequestMsgHeaderId,tRequestMsgBodyId,tRequestMsgClassName,tRequestTimeCreated,tSessionId,tResponseMsgHeaderId)
		Set ^TESTResponseReport(tRequestMsgHeaderId) = list
		//Quit	
	}
	Set ^TEST($I(^TEST)) = "QUIT"
	Quit tSC
}

ClassMethod GetMsgBodyStatusLine(
	pClassName As %String = "",
	pId As %String = "") As %String
{
	//Set tDebug = "GetMsgBodyStatusLine:"_pClassName_" "_pId
	//Do ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	#Dim oMsgBody As EnsLib.HTTP.GenericMessage
	Try {
		Set oMsgBody = $ClassMethod(pClassName,"%OpenId",pId)
		Set tReturn = oMsgBody.HTTPHeaders.GetAt("StatusLine")
	} Catch {
		Set tReturn = "Caught Error"
	}
	Quit tReturn
}

ClassMethod GetMsgBodyURL(
	pClassName As %String = "",
	pId As %String = "") As %String
{
	//Set tDebug = "GetMsgBodyURL"_pClassName_" "_pId
	//Do ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	#Dim oMsgBody As EnsLib.HTTP.GenericMessage
	Try {
		Set oMsgBody = $ClassMethod(pClassName,"%OpenId",pId)
		Set tReturn = oMsgBody.HTTPHeaders.GetAt("URL")
		Set tReturn = $Piece(tReturn,"IncomingFSC/",2,*)
	} Catch {
		Set tReturn = "Caught Error"
	}
	Quit tReturn
}

ClassMethod GetMsgData(
	pSessionId As %String = "",
	pSource As %String = "",
	pServiceMsgHeaderId As %String,
	pDEBUG = 0) As %String
{
	Set tDebug = "GetMsgData: "_pSource_" "_pSessionId_" "_pServiceMsgHeaderId
	Do:pDEBUG ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated, TimeProcessed FROM Ens.MessageHeader"
	//Set tWhere = " WHERE SessionId = ? AND SourceConfigName = ? AND Type = 'Request'"
	Set tWhere = " WHERE SessionId = ? AND SourceConfigName = ? AND ID > ? AND Type = 'Request'"
	Set tOrderBy = " ORDER BY ID ASC"
	Set tQuery = tQuery_$Get(tWhere)_$Get(tOrderBy)
	Do:pDEBUG ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 2  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery)
	Do:pDEBUG ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(qStatus)
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT ""}
	#Dim rset As %SQL.StatementResult
	Set rset = tStatement.%Execute(pSessionId,pSource,pServiceMsgHeaderId)
	Set x = rset.%SQLCODE
	Set tMsgHeaderId = ""
	Set tRespHeaderId = ""
	Set tTarget = ""
	Set tTimeCreated = ""
	Set tTimeProcessed = ""
	While rset.%Next(.tSC) {
		Set tTest = rset.%Get("TargetConfigName")
		If (tTest ? 1"FSCResponseToDMLS".E) { CONTINUE }
		Set tMsgHeaderId = rset.%Get("ID")
		Set tRespHeaderId = rset.%Get("CorrespondingMessageId")
		Set tTimeCreated = rset.%Get("TimeCreated")
		Set tTimeProcessed = rset.%Get("TimeProcessed")
		Set tTarget = tTest
		Quit
	}
	//Write !,$Get(x,0),!
	//DO rset.%Display()
	//WRITE !,"End of data"
	Set tReturn = "^"_tMsgHeaderId_"^"_tTimeCreated_"^"_tTimeProcessed_"^"_tTarget_"^"_tRespHeaderId
	Do:pDEBUG ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tReturn)
	Quit tReturn
}

ClassMethod GetRespData(
	pSessionId As %String = "",
	pSource As %String = "",
	pRespHeaderId As %String,
	pDEBUG = 0) As %String
{
	Set tDebug = "GetRespData: "_pSource_" "_pSessionId
	Do:pDEBUG ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	//Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated, TimeProcessed FROM Ens.MessageHeader"
	//Set tWhere = " WHERE SessionId = ? AND SourceConfigName = ? AND Type = 'Response'"
	Set tQuery = "SELECT MessageBodyId, TimeCreated, TimeProcessed FROM Ens.MessageHeader"
	Set tWhere = " WHERE ID = ?"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 2  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery_tWhere)
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT ""}
	#Dim rset As %SQL.StatementResult
	//Set rset = tStatement.%Execute(pSessionId,pSource)
	Set rset = tStatement.%Execute(pRespHeaderId)
	Set x = rset.%SQLCODE
	Set tMsgBodyId = ""
	Set tTimeCreated = ""
	Set tTimeProcessed = ""
	While rset.%Next(.tSC) {
		Set tMsgBodyId = rset.%Get("MessageBodyId")
		Set tTimeCreated = rset.%Get("TimeCreated")
		Set tTimeProcessed = rset.%Get("TimeProcessed")
	}
	//Write !,$Get(x,0),!
	//DO rset.%Display()
	//WRITE !,"End of data"
	Quit "^"_tMsgBodyId_"^"_tTimeCreated_"^"_tTimeProcessed_"^"_$Get(tTarget)
}

}
