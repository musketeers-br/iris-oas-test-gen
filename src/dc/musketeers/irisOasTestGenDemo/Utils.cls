Class dc.musketeers.irisOasTestGenDemo.Utils Extends %RegisteredObject
{

/// <pre>
/// Deploy a REST application to the server.
/// Note: this method was copied from %SYS.REST class to include the matchRoles parameter.
/// 
/// Parameters:
///    - restApplication (String): The name of the REST application.
///    - webApplication (String): The name of the web application.
///    - authenticationType (String): The type of authentication to use.
///    - matchRoles (String): The roles to match.
/// 
/// Returns:
///    - %Status: Status of the operation.
/// </pre>
ClassMethod DeployApplication(restApplication As %String, webApplication As %String, authenticationType As %String, matchRoles As %String) As %Status
{
	// Remember namespace since only interested in REST applications in this namespace
	Set namespace=$namespace
	
	$$$AddAllRoleTemporary
	New $namespace
	Set $namespace="%SYS"
	
	// Delete web application for this REST application in this namespace.
	Set dispatch=restApplication_".disp"
	Set applications=##class(%SYS.REST).GetRESTApplications()
	Set itr=applications.%GetIterator()
	While itr.%GetNext(.index,.app) {
		If app.namespace=namespace,app.dispatchClass=dispatch,app.name'=webApplication {
			Do ##class(Security.Applications).Delete(app.name)
		}
	}

	// Deploy web application
	If $get(authenticationType)="" Set authenticationType=$$$AutheCache
	Set props("AutheEnabled")=authenticationType
	Set props("DispatchClass")=dispatch
	Set props("NameSpace")=namespace
	Set props("MatchRoles")=matchRoles
	If ##class(Security.Applications).Exists(webApplication) {
		// If web applcation exists modify it to deploy this REST application
		Set sc=##class(Security.Applications).Modify(webApplication,.props)
	} Else {
		// If web applcation does not exist create it to deploy this REST application
		Set sc=##class(Security.Applications).Create(webApplication,.props)
	}
	
	Quit sc
}

}
