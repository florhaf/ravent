<?php

require '../php/facebook-sdk/src/facebook.php';

    $APPLICATION_ID = "299292173427947";
    $APPLICATION_SECRET = "d894ccb29b3fbba3591256dad5d0c1c5";

    $token_url =    "https://graph.facebook.com/oauth/access_token?" .
                    "client_id=" . $APPLICATION_ID .
                    "&client_secret=" . $APPLICATION_SECRET .
                    "&grant_type=client_credentials";
    $app_token = file_get_contents($token_url);

    $facebook = new Facebook(array(

        'appId' => $APPLICATION_ID,
        'secret' => $APPLICATION_SECRET,
    ));

    $event = $facebook->api($_GET['eid']);

    $name = $event['name'];
    $location = $event['location'];
    $pic_url = 'https://graph.facebook.com/' . $_GET['eid'] . '/picture';

?>

<!doctype html>
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!-- Consider adding a manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head xmlns:gemsterapp="https://apps.facebook.com/gemsterapp/ns#">

   <meta property="fb:app_id" content="299292173427947" />
   <meta property="og:type" content="gemsterapp:event" />
   <meta property="og:title" content="<?php echo $name; ?>" />
   <meta property="og:description"content="<?php echo $location; ?>    |    Gemster makes it easy to find and interact with the best local events, anywhere in the world." />
   <meta property="og:image" content="<?php echo $pic_url; ?>" />
   <meta property="og:url" content="http://gemsterapp.com/facebook/event_page.php?eid=<?php echo $_GET['eid']; ?>" />

    <meta charset="utf-8">

    <!-- Use the .htaccess and remove these lines to avoid edge case issues.
 More info: h5bp.com/i/378 -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <title>Gemster</title>
    <meta name="description" content="Gemster mobile app for iOS, help you find the best events happening right now around you">

    <!-- Mobile viewport optimized: h5bp.com/viewport -->
    <meta name="viewport" content="width=device-width">

    <!-- Place favicon.ico and apple-touch-icon.png in the root directory: mathiasbynens.be/notes/touch-icons -->

    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/event_page.css">

    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>

    <script src="../js/ticker/jquery.ticker.js"></script>


<style type="text/css">
#scroller{height:100%;margin:0;padding:0;line-height:70px;position:relative;}
#scroller li{float:left;height:70px;padding:0 0 0 10px;list-style-position:inside;}
    #scrollerWrapper{


        overflow:hidden;


        border: width: 100%; height: 70px; font-size: 40px;
    }
</style>

</head>
<body style="background-color: #3b79ac;">
<!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
chromium.org/developers/how-tos/chrome-frame-getting-started -->
<!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
<header>
    <div id="header" class="header" style="width: 100%; height: 115px; margin: auto auto; text-align: center;">
        <img src="../img/logo.png" width="420px" alt="Gemster Logo" style="margin-left: -140px; z-index: 42;"/>
    </div>
</header>

<div role="main" style="width: 100%; min-width: 1000px; height: 100%; margin: auto auto; background-color: white; text-align: left;background-color: #d3d3d3;">

    <div id="container" style="margin: auto auto; width: 960px;  min-height: 960px; overflow: overflow-x;">

        <div style="width: 640px; min-height: 840px; border-left: 1px solid #a9a9a9; border-right: 1px solid #a9a9a9; border-bottom: 1px solid #a9a9a9; float: left; margin-left: 0px;">

            <div id="top" style="height: 484px; background-image: url(../img/event_details_top.png); background-repeat: no-repeat;">

                <div id="date" style="height: 40px; color: white; font-size: 15px; font-weight: bold; padding-top: 8px;">

                </div>

                <div id="scrollerWrapper">
                    <ul id="scroller"><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li></ul>
                </div>

                <div id="top" style="width: 100%; height: 280px; margin-top: 35px;">

                    <div id="picture" style="width: 280px; height: 280px; margin-left: 20px; margin-top: -10px; float: left; overflow: hidden; display: table-cell; vertical-align: middle;">

                        <img id="img" src="<?php echo ($pic_url . '?type=large'); ?>" style="min-width: 100%; display: none;" alt="event image" />

                    </div>

                    <div id="location" style="width: 270px; height: 90px; margin-left: 30px; float: left; font-size: 30px; text-align: center;">
                        <?php echo $location; ?>
                    </div>

                    <div id="score" style="width: 270px; height: 90px; margin-left: 30px; float: left; display: none;">

                    </div>

                    <div id="ratio" style="width: 270px; height: 90px; margin-left: 30px; float: left; padding-top: 20px; display:none;">
                        <div id="female" style="width: 33%; float: left; text-align: center; font-size: 30px;">

                        </div>
                        <div id="male" style="width: 33%; float: left; text-align: center; font-size: 30px;">

                        </div>
                        <div id="going" style="width: 33%; float: left; text-align: center; font-size: 30px;">

                        </div>
                    </div>

                </div>

                <div id="other" style="width: 100%; height: 40px; margin-top: 20px; display: none;">

                </div>

            </div>

            <div id="middle" style="min-height: 400px; background-image: url(../img/event_details_middle.png); background-repeat: repeat-y;">

                <div id="description" style="width: 90%; min-height: 280px; padding-left: 40px; display: none;">

                </div>

            </div>

            <div id="bottom" style="height: 38px; background-image: url(../img/event_details_bottom.png);">

            </div>

        </div>

        <div id="scrollingDiv" style="width: 300px; height: 840px; margin-top: 35px;  float: right;">

            <div style="width: 300px; height: 311px; background-image: url(../img/frame.png); margin-bottom: 0px;">

                <div id="map" style="margin-left: 10px; margin-top: 10px; width: 280px; height: 280px; display: none;">
                </div>

            </div>

            <div style="width: 300px; height: 100px; ">
                <div class="download-button" style="margin-top: 30px; margin-left: 20px;">
                    <a id="button-get-the-app" href="#" class="button-get-the-app">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get the app</a>
                </div>
                <div id="form-get-the-app" class="form-get-the-app">
                    <div id="form-get-the-app-send-text">
                        Open mobile safari and go to<br/>m.gemsterapp.com or<br/><span
                            style="font-size: 17px; color: white;"><b>email it to your
                        phone...</b></span><br/><br/>
                        <span style="font-size: 12px">Email Address</span>
                        <input id="email" class="twitterStyleTextbox" placeholder="##########"/>
                        <button id="button-send-text" class="button-send-text"></button>
                    </div>
                    <div id="form-get-the-app-sent"
                         style="text-align: center; margin-top: 10px; margin-left: -50px;">
                        A download link has been sent<br/>to your mobile phone.
                    </div>
                </div>

            </div>

            <div id="events" style="width: 300px; height: 311px; background-image: url(../img/frame.png); margin-bottom: 10px; padding: 8px; background-repeat: no-repeat;">
            </div>

            <div style="text-align: center;">
                <iframe src="http://www.facebook.com/plugins/facepile.php?
                    app_id=299292173427947" scrolling="no" frameborder="0" style="border:none;
                    overflow:hidden; width:250px; height: 100px;" allowTransparency="true"></iframe>
            </div>

        </div>

        <div style="clear: both;"></div>

    </div>



</div>

<footer class="footer">
    <table style="margin: 5px auto;">
        <tr>
            <td class="footer-column">
                <a class="footer-link" href="../about/">About</a>
            </td>
            <td class="footer-column">
                <a class="footer-link" href="../faq/">FAQ</a>
            </td>
            <td class="footer-column">
                <a class="footer-link" href="../promoter/">Promoters</a>
            </td>
            <td class="footer-column">
                <a class="footer-link" href="../contactus/">Contact Us</a>
            </td>
            <td class="footer-column">
                <a class="footer-link" href="http://gemsterblog.com" target="_blank">Blog</a>
            </td>
			<td class="footer-column">
                <a class="footer-link" href="../termsofuse/">Terms Of Use</a>
            </td>
            <td class="footer-column">
                <a class="footer-link" href="../privacypolicy/">Privacy Policy</a>
            </td>
        </tr>
    </table>
    <div class="footer-copyrigth">
        © 2012 Gemster Group, Inc. All rights reserved.
    </div>
</footer>

<script>

function getParameterByName(name)
{
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.search);
  if(results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

function onLoadData(data) {

    var results = data.records;
    var size = results.length;

    var div = '';

    for (var i = 0; i < 3; i++) {

        var randomnumber=Math.floor(Math.random()*results.length);

        var e = results[randomnumber];

        div += '<a href="/facebook/event_page.php?eid=' + e.eid + '"><div style="width: 282px; height: 93px; border-bottom: 1px solid lightGray; ">';

            div += '<div style="width: 100%; height: 68px; border: 0px solid green;">';
                div += '<div id="img" style="width: 64px; height: 64px; overflow: hidden; border: 1px solid gray; margin: 5px 5px 0px 5px; box-shadow: 0px 2px 2px #888; float: left;">';
                    div += '<img src="' + e.pic_big + '" alt="other event picture" style="min-width: 100%;" />';
                div += '</div>';

                var name = e.name;
                var location = e.location;

                if (name.length > 22) {
                    name = name.substr(0, 22) + '...';
                }

                if (location.length > 22) {
                    location = location.substr(0, 22) + '...';
                }

                div += '<div id="info" style="float: left; padding-left: 10px; padding-top: 10px;">';
                    div += '<span style="">' + name + '</span><br />';
                    div += '<span style="">' + location + '</span><br />';
                    div += '<div id="score" style="margin-top: 8px;">';
                    for (var j = 0; j < 5; j++) {
                        var imgStr = '<img src="../img/diamondSlot.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
                        if (j < e.score) {
                            imgStr = '<img src="../img/diamond.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
                        }
                        div += imgStr;
                    }
                    div += '</div>';

                div += '</div>';
            div += '</div>'

            div += '<div style="width: 100%; height: 30px; font-size: 10px; color: gray; border: 0px solid blue; margin-top: 8px; margin-left: 5px;">';
                div += '<div style="width: 49%; text-align: left; float: left; border: 0px solid red;">' + e.date_start + '@' + e.time_start + '</div>';
                div += '<div style="width: 49%; text-align: right; float: left; border: 0px solid red;">' + e.distance + ' mi.</div>';
            div += '</div>';

        div += '</div></a>'
    }

    return div;
}

    $("document").ready(function() {



        $('#img').fadeIn();

        $("#form-get-the-app").hide();

        var speed = 5;
        var items, scroller = $('#scroller');
        var width = 0;
        scroller.children().each(function(){
            width += $(this).outerWidth(true);
        });
        scroller.css('width', width);
        scroll();
        function scroll(){
            items = scroller.children();
            var scrollWidth = items.eq(0).outerWidth();
            scroller.animate({'left' : 0 - scrollWidth}, scrollWidth * 100 / speed, 'linear', changeFirst);
        }
        function changeFirst(){
            scroller.append(items.eq(0).remove()).css('left', 0);
            scroll();
        }

        var d = new Date();

        var latitude = '34.094';
        var longitude = '-118.382';

        $.ajax({
            url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://api.gemsterapp.com/events?<?php echo $app_token; ?>&timezone_offset=' + -d.getTimezoneOffset() + '&locale=' + navigator.language.replace('-', '_') + '&timeframe=48&limit=30&latitude=' + latitude + '&longitude=' + longitude),
        }).done(function(data) {
            $('#events').html(onLoadData(data));
        });

        $.ajax({
            url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://api.gemsterapp.com/calendar?eventID=' + getParameterByName('eid') + '&<?php echo $app_token; ?>' + '&timezone_offset=' + -d.getTimezoneOffset() + '&locale=' + navigator.language.replace('-', '_'))
        }).done(function(data) {

            var e = data.records[0];

            var vc = e.venue_category;
            if (vc.length > 35) {

                vc = vc.substr(0, 32) + '...';
            }

            if (e.latitude && e.latitude != null) {

                $.ajax({
                    url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://maps.google.com/maps/api/geocode/json?sensor=true&latlng=' + e.latitude + ',' + e.longitude),
                    crossDomain : true,
                }).done(function(data) {

                    $('#other').html('<div style="width: 40%; float: left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + vc + '</div>' + '<div style="width: 60%; float: left; text-align: right;">' + data.results[0].formatted_address + ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>');
                    $('#other').fadeIn();
                });

                $('#map').html('<img src="http://maps.googleapis.com/maps/api/staticmap?center=' + e.latitude + ',' + e.longitude + '&zoom=13&size=280x280&maptype=roadmap&markers=color:red%7Ccolor:red%7Clabel:%7C' + e.latitude + ',' + e.longitude + '&sensor=false" style="width: 280px; height:280px;margin-top: 9px;" />');

                setTimeout(function() {

                    $('#map').fadeIn();
                }, 100);


            } else {

                $('#map').html('<img src="../img/nomap.png" style="width: 280px; height:280px;margin-top: 9px;" />');

                setTimeout(function() {

                    $('#map').fadeIn();
                }, 100);



                $('#other').html('<div style="width: 50%; float: left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + vc + '</div>' + '<div style="width: 50%; float: left; text-align: right;">unknown address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>');
                $('#other').fadeIn();
            }

            $('#date').html('<div style="width: 50%; float: left;">&nbsp;&nbsp;&nbsp;' + e.date_start + ' to ' + e.date_end + '</div>' + '<div style="width: 50%; float: left; text-align: right;">' + e.time_start + '-' + e.time_end + '&nbsp;&nbsp;&nbsp;</div>');

            var score = '';

            for (var i = 0; i < 5; i++) {

                var img = 'diamondSlot.png';

                if (i < e.score) {

                    img = 'diamond.png';
                }

                score += '<div style="float: left; background-image: url(../img/' + img + '); background-size: 54px 45px; width: 54px; height: 45px;"></div>';
            }

            $('#score').html(score);

            $('#score').fadeIn();
        });

        $.ajax({
            url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://api.gemsterapp.com/description?eid=' + getParameterByName('eid') + '&<?php echo $app_token; ?>')
        }).done(function(data) {

            $desc = data.records[0].description;

            $desc = $desc.replace(/\n/g, '<br />');

            $('#description').html($desc);

            $('#container').css('height', (830 + parseInt($('#description').css('height')) -220) + 'px');

            $('#description').fadeIn();
        });

        $.ajax({
            url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://api.gemsterapp.com/eventstats?eid=' + getParameterByName('eid') + '&<?php echo $app_token; ?>')
        }).done(function(data) {


            if (data.records != null) {

                var e = data.records[0];

                var f = e.female_ratio.toFixed(2);
                var m = (1 - f).toFixed(2);
                var g = e.nb_attending;


                $('#female').html(Math.round((f * 100)) + '%');
                $('#male').html(Math.round(m * 100) + '%');
                $('#going').html(g);
            } else {

                $('#female').html('?');
                $('#male').html('?');
                $('#going').html('?');
            }



            $('#ratio').fadeIn();
        });
    });

    $("#header").click(function() {

        window.location = "../";
    });

    $("#button-get-the-app").click(function () {

        if ($("#form-get-the-app").is(":visible")) {

            $("#form-get-the-app").fadeOut();
        } else {

            $("#form-get-the-app-send-text").show();
            $("#form-get-the-app-sent").hide();

            $("#form-get-the-app").fadeIn();
        }
    });

    $("#button-send-text").click(function () {

        jQuery.ajax('http://gemsterapp.com/php/sendMailFromGemsterApp.php?email=' + $("#email").val());

        $("#form-get-the-app-send-text").fadeOut()
        $("#form-get-the-app-sent").fadeIn();
    });


</script>

</body>
</html>