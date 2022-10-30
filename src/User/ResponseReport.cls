Class User.ResponseReport
{

ClassMethod GetData(pServiceName As %String) As %Status
{
	Set tSC = $$$OK
	//Set tSC = ##class(FSCReport).%DeleteExtent()
	//Set tBegin = "2022-04-28 14:00:00"
	//Set tEnd = "2022-04-28 15:15:00"
	Set tBegin = "2022-10-06 00:01:00"
	Set tEnd = "2022-10-06 23:45:00"
	Set tSQL = ""
	Set tSQL($I(tSQL)) = "SELECT ID, Banked, BusinessProcessId, CorrespondingMessageId, Description, ErrorStatus, Invocation, "
	Set tSQL($I(tSQL)) = "IsError, MessageBodyClassName, MessageBodyId, Priority, Resent, ReturnQueueName, SessionId, "
	Set tSQL($I(tSQL)) = "SourceBusinessType, SourceConfigName, Status, SuperSession, TargetBusinessType, TargetConfigName, "
	Set tSQL($I(tSQL)) = "TargetQueueName, TimeCreated, TimeProcessed, Type FROM Ens.MessageHeader "
	Set tSQL($I(tSQL)) = "WHERE TimeCreated BETWEEN '"_tBegin_"' AND '"_tEnd_"'"
	Set tSQL($I(tSQL)) = " AND SourceConfigName = 'IncomingFSC'"
	Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated FROM Ens.MessageHeader"
	//Set tWhere = " WHERE TimeCreated BETWEEN '"_tBegin_"' AND '"_tEnd_"' AND SourceConfigName = 'IncomingFSC'"
	//Set tWhere = " WHERE TimeCreated BETWEEN ? AND ? AND SourceConfigName = 'IncomingFSC'"
	Set tWhere = ""
	If ($Get(pServiceName) '= "") Set tWhere = " WHERE SourceConfigName = '?'"
	Set tOrderBy = " ORDER BY ID DESC"
	//ZW tQuery
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 1  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery_$Get(tWhere)_$Get(tOrderBy))
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT}
	#Dim rset As %SQL.StatementResult
	//Set rset = tStatement.%Execute(tBegin,tEnd)
	Set rset = tStatement.%Execute(pServiceName)
	Set x = rset.%SQLCODE
	While rset.%Next(.tSC) {
		Set tServiceMsgHeaderId = rset.%Get("ID")
		Set tServiceMsgBodyId = rset.%Get("MessageBodyId")
		Set tServiceMsgClassName = rset.%Get("MessageBodyClassName")
		Set tServiceTimeCreated = rset.%Get("TimeCreated")
		Set tSessionId = rset.%Get("SessionId")
		Set tProcessName = rset.%Get("TargetConfigName")
		Set list = $LB(tServiceMsgHeaderId,tServiceMsgBodyId,tServiceMsgClassName,tServiceTimeCreated,tSessionId,tProcessName)
		Set ^TESTResponseReport(tServiceMsgHeaderId) = list
		Quit	
	}
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
	pSource As %String = "") As %String
{
	//Set tDebug = "GetMsgData: "_pSource_" "_pSessionId
	//Do ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated, TimeProcessed FROM Ens.MessageHeader"
	Set tWhere = " WHERE SessionId = ? AND SourceConfigName = ? AND Type = 'Request'"
	//ZW tQuery
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 2  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery_tWhere)
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT ""}
	#Dim rset As %SQL.StatementResult
	Set rset = tStatement.%Execute(pSessionId,pSource)
	Set x = rset.%SQLCODE
	Set tMsgHeaderId = ""
	Set tTarget = ""
	Set tTimeCreated = ""
	Set tTimeProcessed = ""
	While rset.%Next(.tSC) {
		Set tTest = rset.%Get("TargetConfigName")
		If (tTest ? 1"FSCResponseToDMLS".E) { CONTINUE }
		Set tMsgHeaderId = rset.%Get("ID")
		Set tTimeCreated = rset.%Get("TimeCreated")
		Set tTimeProcessed = rset.%Get("TimeProcessed")
		Set tTarget = tTest
	}
	//Write !,$Get(x,0),!
	//DO rset.%Display()
	//WRITE !,"End of data"
	Quit "^"_tMsgHeaderId_"^"_tTimeCreated_"^"_tTimeProcessed_"^"_tTarget
}

ClassMethod GetRespData(
	pSessionId As %String = "",
	pSource As %String = "") As %String
{
	//Set tDebug = "GetRespData: "_pSource_" "_pSessionId
	//Do ##class(HS.Local.VA.eSCM.DMLSS.Debug).DebugTEST(tDebug)

	Set tQuery = "SELECT ID, CorrespondingMessageId, ErrorStatus, MessageBodyClassName, MessageBodyId, SessionId, Status, TargetConfigName, TimeCreated, TimeProcessed FROM Ens.MessageHeader"
	Set tWhere = " WHERE SessionId = ? AND SourceConfigName = ? AND Type = 'Response'"
	//ZW tQuery
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 2  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
	Set qStatus = tStatement.%Prepare(tQuery_tWhere)
	If qStatus'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT ""}
	#Dim rset As %SQL.StatementResult
	Set rset = tStatement.%Execute(pSessionId,pSource)
	Set x = rset.%SQLCODE
	//Set tMsgHeaderId = ""
	Set tMsgBodyId = ""
	//Set tTarget = ""
	Set tTimeCreated = ""
	Set tTimeProcessed = ""
	While rset.%Next(.tSC) {
		//Set tTest = rset.%Get("TargetConfigName")
		//If (tTest ? 1"FSCResponseToDMLS".E) { CONTINUE }
		//Set tMsgHeaderId = rset.%Get("ID")
		Set tMsgBodyId = rset.%Get("MessageBodyId")
		Set tTimeCreated = rset.%Get("TimeCreated")
		Set tTimeProcessed = rset.%Get("TimeProcessed")
		//Set tTarget = tTest
	}
	//Write !,$Get(x,0),!
	//DO rset.%Display()
	//WRITE !,"End of data"
	Quit "^"_tMsgBodyId_"^"_tTimeCreated_"^"_tTimeProcessed_"^"_$Get(tTarget)
}

}
