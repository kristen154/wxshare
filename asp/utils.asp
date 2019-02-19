<%
	'把标准时间转换为UNIX时间戳
	Function ToUnixTime(strTime, intTimeZone)
	    If IsEmpty(strTime) or Not IsDate(strTime) Then strTime = Now
	    If IsEmpty(intTimeZone) or Not isNumeric(intTimeZone) Then intTimeZone = 0
	    ToUnixTime = DateAdd("h",-intTimeZone,strTime)
	    ToUnixTime = DateDiff("s","1970-01-01 00:00:00", ToUnixTime)
	End Function
%>