<!--#include file="jssdk.asp" -->
<%
dim js,qs
qs = request.querystring("url")	
set js = new JSSDK
response.write js.getSignPackage(qs)
%>