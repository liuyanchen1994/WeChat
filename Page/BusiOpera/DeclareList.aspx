﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeclareList.aspx.cs" Inherits="WeChat.Page.BusiOpera.DeclareList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<%-- <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>--%>
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1">
    <title>报关单查询</title>
    <link href="/css/iconfont/iconfont.css" rel="stylesheet" />
    <link rel="stylesheet" href="//g.alicdn.com/msui/sm/0.6.2/css/sm.min.css">
    <%--<link rel="stylesheet" href="//g.alicdn.com/msui/sm/0.6.2/css/??sm.min.css,sm-extend.min.css">--%>
    <script type='text/javascript' src='//g.alicdn.com/sj/lib/zepto/zepto.min.js' charset='utf-8'></script>

    <style>
        body,html{
            font-size:14px;
        }
        page-infinite-scroll-bottom .bar{
            height:6rem;
        }
        .button{
            height:2.2em;
            font-size:.85rem;
        }
        .button.button-fill{
            line-height:2.2em;
        }
        .list-block{
            margin:.3rem 0;
        }
        .bar input[type=search]{
            height:2rem;
        }
        .bar-nav~.content{
            top:7rem;
        }
        .search-input input{
            padding:.5rem;
        }
        .bar-tab{
            height:2.8rem;
        }
    </style>

    <script type="text/javascript">
        $(function () {
            //----------------------------------------------------------------------------------------------------------------查询条件
            $("#txt_startdate").calendar({});
            $("#txt_enddate").calendar({});          
            $(document).on('click', '.open-tabs-modal', function () {
                $.modal({
                    title: '更多查询',
                    text: '<div class="list-block">' +
                              '<ul>' +
                                '<li>' +
                                  '<div class="item-content">' +
                                    '<div class="item-inner">' +
                                      '<div class="item-title label">业务类型</div>' +
                                      '<div class="item-input"><input type="text" placeholder="选择业务类型" id="picker_busitype" readonly/></div>' +
                                    '</div>' +
                                  '</div>' +
                                '</li>' +
                                '<li>' +
                                  '<div class="item-content">' +
                                    '<div class="item-inner">' +
                                      '<div class="item-title label">删改单</div>' +
                                      '<div class="item-input"><input type="text" placeholder="选择删改单" id="picker_modifyflag" readonly/></div>' +
                                    '</div>' +
                                  '</div>' +
                                '</li>' +
                                '<li>' +
                                  '<div class="item-content">' +
                                    '<div class="item-inner">' +
                                      '<div class="item-title label">海关状态</div>' +
                                      '<div class="item-input"><input type="text" placeholder="选择海关状态" id="picker_customsstatus" readonly/></div>' +
                                    '</div>' +
                                  '</div>' +
                                '</li>' +
                              '</ul>' +
                            '</div>',
                    buttons: [
                     {
                         text: '重置',
                         onClick: function () {
                             //$.alert('You clicked first button!')
                         }
                     }
                    ]
                });

                $("#picker_busitype").picker({
                    toolbarTemplate: '<header class="bar bar-nav">\
                      <button class="button button-link pull-right close-picker">确定</button>\
                      <h1 class="title">请选择业务类型</h1>\
                      </header>',
                    cols: [
                      {
                          textAlign: 'center',
                          values: ['空运进口', '空运出口', '海运进口', '海运出口', '陆运进口', '陆运出口', '国内业务', '特殊进口', '特殊出口']
                      }
                    ]
                });
                $("#picker_modifyflag").picker({
                    toolbarTemplate: '<header class="bar bar-nav">\
                      <button class="button button-link pull-right close-picker">确定</button>\
                      <h1 class="title">请选择删改单</h1>\
                      </header>',
                    cols: [
                      {
                          textAlign: 'center',
                          values: ['未改单完成', '未删单完成', '改单完成', '删单完成']
                      }
                    ]
                });
                $("#picker_customsstatus").picker({
                    toolbarTemplate: '<header class="bar bar-nav">\
                      <button class="button button-link pull-right close-picker">确定</button>\
                      <h1 class="title">请选择海关状态</h1>\
                      </header>',
                    cols: [
                      {
                          textAlign: 'center',
                          values: ['未结关', '已结关', '未放行', '已放行']
                      }
                    ]
                });

            });

            //---------------------------------------------------------------------------------------------------------------------
            var loading = false;
            var itemsPerLoad = 10;// 每次加载添加多少条目                
            var maxItems = 20;// 最多可加载的条目
            var lastIndex = 0;//$('.list-block').length;//.list-container li       

            $(document).on('click', '.open-preloader-title', function () {
                $.showPreloader('加载中...');
                setTimeout(function () {
                    //首次查询需要置为初始值
                    $('#div_list').html("");
                    loading = false; itemsPerLoad = 10; lastIndex = 0;
                    var scroller = $('.native-scroll');

                    //首次查询，需要加载监听事件及加载符号
                    $('.infinite-scroll-preloader').show();
                    $.attachInfiniteScroll($('.infinite-scroll'));

                    loaddata(itemsPerLoad, lastIndex);
                    lastIndex = $('.list-block').length;// 更新最后加载的序号
                    $.refreshScroller();
                    scroller.scrollTop(0); //首次查询后，滚动条需要置为初始值0

                    if (lastIndex < itemsPerLoad) {
                        $.detachInfiniteScroll($('.infinite-scroll'));// 加载完毕，则注销无限加载事件，以防不必要的加载     
                        $('.infinite-scroll-preloader').hide();

                        if (lastIndex == 0) { $.toast("没有符合的数据！"); }
                        else { $.toast("已经加载到最后"); }
                    }

                    $.hidePreloader();
                }, 500);
            });

            //无限滚动
            $(document).on("pageInit", "#page-infinite-scroll-bottom", function (e, id, page) {
                $('.infinite-scroll-preloader').hide();

                $(page).on('infinite', function () {
                    if (loading) return;// 如果正在加载，则退出                    
                    loading = true;// 设置flag

                    $('.infinite-scroll-preloader').show();
                    $.attachInfiniteScroll($('.infinite-scroll'));

                    setTimeout(function () {
                        loading = false;// 重置加载flag
                        if (lastIndex >= maxItems || lastIndex % itemsPerLoad != 0) {
                            $.detachInfiniteScroll($('.infinite-scroll'));// 加载完毕，则注销无限加载事件，以防不必要的加载     
                            $('.infinite-scroll-preloader').hide();

                            $.toast("已经加载到最后");
                            return;
                        }

                        loaddata(itemsPerLoad, lastIndex);

                        if (lastIndex == $('.list-block').length) {
                            $.detachInfiniteScroll($('.infinite-scroll'));// 加载完毕，则注销无限加载事件，以防不必要的加载     
                            $('.infinite-scroll-preloader').hide();

                            $.toast("已经加载到最后");
                            return;
                        }
                        lastIndex = $('.list-block').length;// 更新最后加载的序号
                        $.refreshScroller();

                    }, 500);
                });
            });

            $.init();
            //----------------------------------------------------------------------------------------------------------------------------------------
            function loaddata(itemsPerLoad, lastIndex) {
                $.ajax({
                    type: "post", //要用post方式                 
                    url: "DeclareList.aspx/BindList",//方法所在页面和方法名
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: "{'declcode':'" + $("#txt_declcode").val() + "','startdate':'" + $("#txt_startdate").val() + "','enddate':'" + $("#txt_enddate").val()
                        + "','start':" + lastIndex + ",'itemsPerLoad':" + itemsPerLoad + "}",
                    cache: false,
                    async: false,//默认是true，异步；false为同步，此方法执行完在执行下面代码
                    success: function (data) {
                        var obj = eval("(" + data.d + ")");//将字符串转为json

                        var tb = ""; 
                        for (var i = 0; i < obj.length; i++) {
                            tb = '<div class="list-block">'
                                    + '<ul>'
                                        + '<li class="item-content">'
                                             + '<div class="item-inner row">'
                                                + '<div class="item-title col-50">' + obj[i]["DECLARATIONCODE"] + '</div>'
                                                + '<div class="item-title col-33">' + getname("BUSITYPE", obj[i]["BUSITYPE"]) + '</div>'
                                                + '<div class="item-title col-15">' + obj[i]["TRADEMETHOD"] + '</div>'
                                            + '</div>'
                                        + '</li>'
                                        + '<li class="item-content">'
                                            + '<div class="item-inner row">'
                                                + '<div class="item-title col-50">' + obj[i]["CONSIGNEESHIPPERNAME"] + '</div>'
                                                + '<div class="item-title col-33">' + obj[i]["CONTRACTNO"] + '</div>'
                                                + '<div class="item-title col-15">' + (obj[i]["REPTIME"] == null ? "" : obj[i]["REPTIME"]) + '</div>'
                                            + '</div>'
                                        + '</li>'
                                        + '<li class="item-content">'
                                            + '<div class="item-inner row">'
                                                + '<div class="item-title col-50">' + obj[i]["TRANSNAME"] + '</div>'
                                                + '<div class="item-title col-33">' + obj[i]["GOODSNUM"] + '/' + obj[i]["GOODSGW"] + '</div>'
                                                + '<div class="item-title col-15">' + getname("MODIFYFLAG", obj[i]["MODIFYFLAG"]) + '</div>'
                                            + '</div>'
                                        + '</li>'
                                        + '<li class="item-content">'
                                            + '<div class="item-inner row">'
                                                + '<div class="item-title col-50">' + obj[i]["BLNO"] + '</div>'
                                                + '<div class="item-title col-33">' + obj[i]["CUSNO"] + '</div>'
                                                + '<div class="item-title col-15">' + obj[i]["CUSTOMSSTATUS"] + '</div>'
                                            + '</div>'
                                        + '</li>'
                                    + '</ul>'
                             + '</div>';

                            $('#div_list').append(tb);
                            tb = ""; objname = "";
                        }

                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {//请求失败处理函数
                        //alert(XMLHttpRequest.status);
                        //alert(XMLHttpRequest.readyState);
                        //alert(textStatus);
                        alert('error...状态文本值：' + textStatus + " 异常信息：" + errorThrown);
                    }
                });
            }
        });


        function getname(key, value) {
            var str = "";
            if (key == "BUSITYPE") {
                switch (value) {
                    case "10": str = "空运出口"; break;
                    case "11": str = "空运进口"; break;
                    case "20": str = "海运出口"; break;
                    case "21": str = "海运进口"; break;
                    case "30": str = "陆运出口"; break;
                    case "31": str = "陆运进口"; break;
                    case "40": str = "国内出口"; break;
                    case "41": str = "国内进口"; break;
                    case "50": str = "特殊出口"; break;
                    case "51": str = "特殊进口"; break;
                }
            }
            if (key == "MODIFYFLAG") {
                switch (value) {
                    case 0: str = "正常"; break;
                    case 1: str = "删单"; break;
                    case 2: str = "改单"; break;
                    case 3: str = "改单完成"; break;
                }
            }

            return str;
        }
        
    </script>
</head>
<body>

    <div class="page-group">
        <div id="page-infinite-scroll-bottom" class="page page-current">
            <%--search --%>
            <header class="bar bar-nav">
                <div class="search-input">                    
                    <div class="row"> 
                        <label style="float:left; width:25%; margin-left:4%; height:2rem; padding-top:.8rem">报关单号：</label>
                        <input style="float:left; width:70%;padding:.5rem; " type="search" id='txt_declcode' placeholder='请输入18位或9位报关单号...'/>
                        <%--<div class="col-100"><input type="search" id='txt_hscode' placeholder='请输入18位或9位报关单号...'/></div>--%>
                    </div>
                    <div class="row">
                        <div style="float:left; width:25%; margin-left:4%; height:2rem; padding-top:.8rem">申报日期：</div>
                        <div style="float:left; width:28%;"><input type="search" id='txt_startdate' placeholder='起始日期'/></div>
                        <div style="float:left; width:3%; height:2rem; padding-top:.8rem;margin-left:1%;margin-right:1%;">~</div>
                        <div style="float:left; width:28%;"><input type="search" id='txt_enddate' placeholder='结束日期'/></div>                        
                        <div style="float:left; width:9%; margin-left:1%;"><a href="#" class="open-tabs-modal"><i class="iconfont" style="font-size:1.65rem;color:gray;">&#xe6ca;</i></a></div>

                        <%--<div class="col-40"><input type="search" id='txt_startdate' placeholder='申报起始日期'/></div>
                        <div class="col-10"></div>
                        <div class="col-40"><input type="search" id='txt_enddate' placeholder='申报结束日期'/></div>
                        <div class="col-10"><a href="#" class="open-tabs-modal"><i class="iconfont" style="font-size:1.3rem;color:gray;">&#xe6ca;</i></a></div>--%>
                    </div>                    
                </div>                
                <a href="#" id="search_a" class="open-preloader-title button button-fill"><span class="icon icon-search"></span>&nbsp;查询</a>   
            </header>

            <%--工具栏 --%>
            <nav class="bar bar-tab">
              <a class="tab-item external active" href="#">
                <span class="icon icon-menu"></span>
                <span class="tab-label">关联报关单信息</span>
              </a>
              <a class="tab-item external" href="#">
                <span class="icon icon-edit"></span>
                <span class="tab-label">删改单维护</span>
                <%--<span class="badge">2</span>--%>
              </a>
              <a class="tab-item external" href="#">
                <span class="icon icon-message"></span>
                <span class="tab-label">报关单调阅</span>
              </a>
            </nav>

           <%--body --%>
            <div class="content infinite-scroll native-scroll" data-distance="100">
                <div id="div_list"></div>

                <!-- 加载提示符 -->
                <div class="infinite-scroll-preloader">
                  <div class="preloader"></div>
                </div>
            </div>

            
        </div>
    </div>  



    <script type='text/javascript' src='//g.alicdn.com/msui/sm/0.6.2/js/sm.min.js' charset='utf-8'></script>   
   <%-- <script type='text/javascript' src='//g.alicdn.com/msui/sm/0.6.2/js/sm-extend.min.js' charset='utf-8'></script>
    <script type="text/javascript" src="//g.alicdn.com/msui/sm/0.6.2/js/sm-city-picker.min.js" charset="utf-8"></script>--%>
</body>
</html>