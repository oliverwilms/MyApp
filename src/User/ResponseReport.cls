Class User.ResponseReport
{

ClassMethod GetData(pServiceName As %String) As %Status
{
    //Set ^TEST($I(^TEST))="GetData"
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
	If ($Get(pServiceName) '= "") Set tWhere = " WHERE SourceConfigName = ?"
	Set tOrderBy = " ORDER BY ID DESC"
	//ZW tQuery
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatement.%SelectMode = 1  // 0 for LOGICAL mode, 1 for ODBC mode, 2 for DISPLAY mode.
    Set tQuery = tQuery_$Get(tWhere)_$Get(tOrderBy)
    //Set ^TEST($I(^TEST))=tQuery
	Set qStatus = tStatement.%Prepare(tQuery)
	//Set ^TEST($I(^TEST))=qStatus
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

}
