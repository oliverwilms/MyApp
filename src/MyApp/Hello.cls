/// Created using the page template: Default
Class MyApp.Hello Extends %ZEN.Component.page [ Language = objectscript ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "MyApp.Application";

/// Displayed name of this page.
Parameter PAGENAME;

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Hello">
<tablePane id="table" OnCreateResultSet="CreateRS" OnExecuteResultSet="ExecuteRS">
<parameter value="Z"/>
</tablePane>
</page>
}

Method CreateRS(
	Output tSC As %Status,
	pInfo As %ZEN.Auxiliary.QueryInfo) As %ResultSet
{
}

Method ExecuteRS(
	myRS As %ResultSet,
	Output pSC As %Status,
	pInfo As %ZEN.Auxiliary.QueryInfo) As %Boolean
{
}

}
