$(function(){
    var url = location.href.split('#')[0].toString();//url不能写死
    $.ajax({
            type : "get",
            url : "share.asp",
            dataType : "json",
            async : false,
            data:{url:url},
            success : function(data) {

        wx.config({
                    debug: false,////生产环境需要关闭debug模式
                    appId: data.appId,//appId通过微信服务号后台查看
                    timestamp: data.timestamp,//生成签名的时间戳
                    nonceStr: data.nonceStr,//生成签名的随机字符串
                    signature: data.signature,//签名
                    jsApiList: [//需要调用的JS接口列表
                        'checkJsApi',
                        'onMenuShareTimeline',
                        'onMenuShareAppMessage',
                        'onMenuShareQQ',
                        'onMenuShareWeibo'
                    ]
                });
            },
            error:function(xhr, status, error){
            
            }
    })
    var meta = document.getElementsByTagName('meta'); 
    var share_desc = ''; 
    for(i in meta){ 
        if(typeof meta[i].name!="undefined"&&meta[i].name.toLowerCase()=="description"){ 
            share_desc = meta[i].content; //获取网页描述作为分享描述
        } 
    }
    var wstitle = document.title //此处填写分享标题
    var wsdesc = share_desc; //此处填写分享简介
    var wslink = url; //此处获取分享链接
    var wsimglink = document.getElementsByTagName('link');
    var wsimg = "";
    for(j in wsimglink){
        if(typeof wsimglink[j].rel!="undefined"&&wsimglink[j].rel.toLowerCase()=="shortcut icon")
            wsimg = wsimglink[j].href//此处获取分享缩略图
    }

    wx.ready(function () {

        // 分享到朋友圈
        wx.onMenuShareTimeline({
                title: wstitle,
                link: wslink,
                imgUrl: wsimg,
                success: function () {
                        
                },
                cancel: function () {
                }
        });

        // 分享给朋友
        wx.onMenuShareAppMessage({
                title: wstitle,
                desc: wsdesc,
                link: wslink,
                imgUrl: wsimg,
                success: function () {
                    
                },
                cancel: function () {
                }
        });

        // 分享到QQ
        wx.onMenuShareQQ({
                title: wstitle,
                desc: wsdesc,
                link: wslink,
                imgUrl: wsimg,
                success: function () {
                        
                },
                cancel: function () {
                }
        });

        // 微信到腾讯微博
        wx.onMenuShareWeibo({
                title: wstitle,
                desc: wsdesc,
                link: wslink,
                imgUrl: wsimg,
                success: function () {
                        
                },
                cancel: function () {
                }
        });

        // 分享到QQ空间
        wx.onMenuShareQZone({
                title: wstitle,
                desc: wsdesc,
                link: wslink,
                imgUrl: wsimg,
                success: function () {
                        
                },
                cancel: function () {
                }
        });

    });

})