<!--#include file="../inc/AspCms_SettingClass.asp" -->

<%
Session.codepage=65001

'组合回复字符串
Function transmixText(fromusername,tousername,time,returnstr)
  dim strresponse
  strresponse ="<xml>" &_
    "<ToUserName><![CDATA["&fromusername&"]]></ToUserName>" &_
    "<FromUserName><![CDATA["&tousername&"]]></FromUserName>" &_
    "<CreateTime>"&time&"</CreateTime>" &_
    "<MsgType><![CDATA[text]]></MsgType>" &_
    "<Content><![CDATA[" & returnstr & "]]></Content>" &_
    "<FuncFlag>0<FuncFlag>" &_
    "</xml>"
  transmixText = strresponse
End Function

'返回扫码类型与内容'
Function getQrcode(qr)
  dim returnType,isTiao,tiaoErr
  returnType = "二维码："
  tiaoErr = ""
  isTiao = instr(qr,",")   '用来判断是否为条形码
  if isTiao>0 then         '如果存在逗号即为条形码
    returnType = "条形码："
    qr = mid(qr,isTiao+1)  '取出逗号后边内容即条形码内容
  end if

  getQrcode = returnType + qr
End Function



dim ToUserName  
dim FromUserName
dim CreateTime  
dim MsgType   
dim Content   
dim MsgId   
dim eventType
dim qrcode,xml_dom ,qrcodecount,returnStr
set xml_dom = Server.CreateObject("MSXML2.DOMDocument")

'xml_dom.async = false 
xml_dom.load request '解析xml
if xml_dom.parseError.errorCode <>0 then
response.end
end if
ToUserName=xml_dom.getelementsbytagname("ToUserName").item(0).text
FromUserName=xml_dom.getelementsbytagname("FromUserName").item(0).text
MsgType=xml_dom.getelementsbytagname("MsgType").item(0).text
select case MsgType
  case "text" 
    'Content = xml_dom.getelementsbytagname("Content").item(0).text
    response.end
  case "event"
    eventType=  xml_dom.getelementsbytagname("Event").item(0).text
    eventType = LCase(eventType)
    if(eventType="click") then 
      content = xml_dom.getelementsbytagname("EventKey").item(0).text
    elseif eventType = "scancode_waitmsg" then
      qrcode = xml_dom.getelementsbytagname("ScanResult").item(0).text
      content = qrcode
      content = getQrcode(qrcode)
    end if
end select
set xml_dom=Nothing
response.AddHeader "charset","utf-8"
Response.write(transmixText(FromUserName,ToUserName,now(),Content))
%>

<%
'response.write request("echostr")'微信后台修改url时使用
%>
