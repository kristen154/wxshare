<!--#include file="sha1.asp" -->
<!--#include file="utils.asp" -->
<%
Session.codepage=65001 '设置程序的字符集为utf-8
Class JSSDK
	Private appId
	Private appSecret
	Private access_token_file
	Private jsapi_ticket_file
	Private Sub Class_Initialize
		appId  = "yourappid"
		appSecret = "your appsecret"
		access_token_file = "access_token.asp"
		jsapi_ticket_file = "jsapi_ticket.asp"
	End Sub
	

	Public Function getSignPackage(url)
		dim nonceStr,jsapiTicket,nowtime,jsstr,returnStr
		nonceStr = createNonceStr(6)
		jsapiTicket = getJsApiTicket
		nowtime = ToUnixTime(now(),0)
		jsstr = "jsapi_ticket="&jsapiTicket&"&noncestr="&nonceStr&"&timestamp="&nowtime&"&url="&url
		signature = SHA1(jsstr)
		returnStr = "{""appId"": """&appId&""",""nonceStr"":"""&nonceStr&""",""timestamp"":"""&nowtime&""",""url"":"""&url&""",""signature"":"""&signature&""",""rawString"":"""&jsstr&"""}"
		getSignPackage = returnStr
	End Function 

	'随机字符函数'
	Private function createNonceStr(length)
		dim chars,str,i,seedLength
		chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		seedLength  = Len(chars)
		str = ""
		Randomize
		for i=0 to length
			str = str + Mid(chars,Int(seedLength*Rnd)+1,1)
		next
		createNonceStr = str
	End Function


    '读文件'
    Private Function get_asp_file(FileUrl,CharSet)
    	dim str
	    set stm=server.CreateObject("adodb.stream")
	    stm.Type=2 '以本模式读取
	    stm.mode=3 
	    stm.charset=CharSet
	    stm.open
	    stm.loadfromfile server.MapPath(FileUrl)
	    str=stm.readtext
	    stm.Close
	    set stm=nothing
	    get_asp_file=str
    End Function

    '写文件'
    Private Function set_asp_file(FileUrl,Byval Str,CharSet)
	    set stm=server.CreateObject("adodb.stream")
	    stm.Type=2 '以本模式读取
	    stm.mode=3
	    stm.charset=CharSet
	    stm.open
	        stm.WriteText str
	    stm.SaveToFile server.MapPath(FileUrl),2 
	    stm.flush
	    stm.Close
	    set stm=nothing
    End Function

    '发送get请求'
    Public Function GetBody(weburl) 
		Dim ObjXMLHTTP 
		Set ObjXMLHTTP=Server.CreateObject("MSXML2.serverXMLHTTP") 
		ObjXMLHTTP.Open "GET",weburl,False 
		ObjXMLHTTP.send 
		While ObjXMLHTTP.readyState <> 4 
		ObjXMLHTTP.waitForResponse 10000 
		Wend 
		GetBody=ObjXMLHTTP.responseBody 
		Set ObjXMLHTTP=Nothing 
	End Function

	'post 请求
	public Function PostBody(url,data)
		set Http=server.createobject("MSXML2.SERVERXMLHTTP")
		Http.open "POST",url,false 
		Http.setRequestHeader "CONTENT-TYPE", "application/x-www-form-urlencoded" 
		Http.send(data) 
		if Http.readystate<>4 then 
		exit function 
		End if
		PostHTTPPage=BytesToBstr(Http.responseBody,"utf-8") 
		PostBody = PostHTTPPage
		set http=nothing 
		if err.number<>0 then err.Clear 
	end Function 

	'解析
	Public  Function BytesToBstr(body,Cset) 
		dim objstream 
		set objstream = Server.CreateObject("adodb.stream") 
		objstream.Type = 1 
		objstream.Mode =3 
		objstream.Open 
		objstream.Write body 
		objstream.Position = 0 
		objstream.Type = 2 
		objstream.Charset = Cset 
		BytesToBstr = objstream.ReadText 
		objstream.Close 
		set objstream = nothing 
	End Function

	'获取对应关键字函数
	Public Function GetContent(str,start,last,n)
		 If Instr(lcase(str),lcase(start))>0 then
		  select case n
		  case 0 '左右都截取（都取前面）（去除关键字）
		  GetContent=Right(str,Len(str)-Instr(lcase(str),lcase(start))-Len(start)+1)
		  GetContent=Left(GetContent,Instr(lcase(GetContent),lcase(last))-1)
		  case 1 '左右都截取（都取前面）（保留关键字）
		  GetContent=Right(str,Len(str)-Instr(lcase(str),lcase(start))+1)
		  GetContent=Left(GetContent,Instr(lcase(GetContent),lcase(last))+Len(last)-1)
		  case 2 '只往右截取（取前面的）（去除关键字）
		  GetContent=Right(str,Len(str)-Instr(lcase(str),lcase(start))-Len(start)+1)
		  case 3 '只往右截取（取前面的）（包含关键字）
		  GetContent=Right(str,Len(str)-Instr(lcase(str),lcase(start))+1)
		  case 4 '只往左截取（取后面的）（包含关键字）
		  GetContent=Left(str,InstrRev(lcase(str),lcase(start))+Len(start)-1)
		  case 5 '只往左截取（取后面的）（去除关键字）
		  GetContent=Left(str,InstrRev(lcase(str),lcase(start))-1)
		  case 6 '只往左截取（取前面的）（包含关键字）
		  GetContent=Left(str,Instr(lcase(str),lcase(start))+Len(start)-1)
		  case 7 '只往右截取（取后面的）（包含关键字）
		  GetContent=Right(str,Len(str)-InstrRev(lcase(str),lcase(start))+1)
		  case 8 '只往左截取（取前面的）（去除关键字）
		  GetContent=Left(str,Instr(lcase(str),lcase(start))-1)
		  case 9 '只往右截取（取后面的）（包含关键字）
		  GetContent=Right(str,Len(str)-InstrRev(lcase(str),lcase(start)))
		  end select
		 Else
		  GetContent=""
		 End if
	End function

	Public Function GetAccess_token()
		dim pcontent,Access_token,expire_time,url,CacheStr,CacheAccess_token,Cache_time,now_time
		CacheStr = get_asp_file(access_token_file,"gb2312")
		CacheStr = Mid(CacheStr,18)'删除前缀'
		Cache_time = GetContent(Mid(CacheStr ,17),"""expire_time"":","}",0)
		if DateDiff("s", Cache_time, now()) > 0 then '如果现在时间大于过期时间'
			url="https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" & appId  &"&secret="& appSecret 
			pcontent=BytesToBstr(GetBody(url),"utf-8")
			Access_token=trim(GetContent(pcontent,"""access_token"":""",""",",0))
			expire_time = DateAdd("h",2,now())
			'写文件'
			CacheStr = chr(60) & chr(37) & "response.end" & chr(37) & chr(62) & "{""access_token"":"""&Access_token&""",""expire_time"":"&expire_time&"}"
			set_asp_file access_token_file,CacheStr,"utf-8"
			GetAccess_token = Access_token

		else 
			GetAccess_token = GetContent(CacheStr,"""access_token"":""",""",",0)
			'GetAccess_token =CacheStr
		end if
		
	End Function

	Public Function getJsApiTicket()
		dim pcontent,Access_token,expire_time,url,CacheStr,CacheAccess_token,Cache_time,now_time,ticket
		CacheStr = get_asp_file(jsapi_ticket_file,"gb2312")
		CacheStr = Mid(CacheStr,18)'删除前缀'
		Cache_time = GetContent(CacheStr,"""expire_time"":","}",0)
		if DateDiff("s", Cache_time, now()) > 0 then '如果现在时间大于过期时间'
			Access_token = GetAccess_token()
			url="https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=jsapi&access_token=" &Access_token
			pcontent=BytesToBstr(GetBody(url),"utf-8")
			ticket=trim(GetContent(pcontent,"""ticket"":""",""",",0))
			expire_time = DateAdd("h",2,now())
			'写文件'
			CacheStr = chr(60) & chr(37) & "response.end" & chr(37) & chr(62) & "{""ticket"":"""&ticket&""",""expire_time"":"&expire_time&"}"
			set_asp_file jsapi_ticket_file,CacheStr,"utf-8"
			getJsApiTicket =ticket

		else 
			getJsApiTicket = GetContent(CacheStr,"""ticket"":""",""",",0)
			'getJsApiTicket = "old"
		end if
	End Function
End Class



%>