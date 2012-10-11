<?php

require '../php/facebook-sdk/src/facebook.php';

    $APPLICATION_ID = "299292173427947";
    $APPLICATION_SECRET = "d894ccb29b3fbba3591256dad5d0c1c5";

    $token_url =    "https://graph.facebook.com/oauth/access_token?" .
                    "client_id=" . $APPLICATION_ID .
                    "&client_secret=" . $APPLICATION_SECRET .
                    "&grant_type=client_credentials";
    $app_token = file_get_contents($token_url);
    $app_token = "access_token=AAADRmCDizJoBACf5T4Me2cbwyyppRA4sq45I5QY1Grb7iIzZB9VfZCgANHxKgNuDfxJW6euMwqydwpBSsGfwxKRzqfSiMcVGXWNiRNSAZDZD";

    $event_url = "http://api.gemsterapp.com/calendar?" . $app_token . "&timezone_offset=-420&eventID=" . $_GET['eid'];
    $json = file_get_contents($event_url);
    $obj = json_decode($json);

    $name = $obj->records[0]->name;
    $location = $obj->records[0]->location;
    $pic_url = $obj->records[0]->pic_big;
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

    <!-- Use the .htaccess and remove these lines to avoid edge case issues. More info: h5bp.com/i/378 -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <title>Gemster | The Social Event Finder</title>
    <meta name="description" content="Gemster mobile app for iOS, help you find the best events happening right now around you">

    <!-- Mobile viewport optimized: h5bp.com/viewport -->
    <meta name="viewport" content="width=device-width">

    <!-- Place favicon.ico and apple-touch-icon.png in the root directory: mathiasbynens.be/notes/touch-icons -->

    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/event_page.css">

    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>

	<style type="text/css">
		#scroller{height:100%;margin:0;padding:0;line-height:70px;position:relative;}
		#scroller li{float:left;height:70px;padding:0 0 0 10px;list-style-position:inside;}
	    #scrollerWrapper{
	        position:relative;
	        overflow:hidden;
	        width: 100%; height: 70px; font-size: 40px;
	    }
	</style>
    
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>

    <script type="text/javascript">var switchTo5x=true;</script>
    <script type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>
    <script type="text/javascript">stLight.options({publisher: "d14cad4a-5dee-4b3f-bfc8-66d7a313d7ca"}); </script>

    <script src="../js/ticker/jquery.ticker.js"></script>

    <script type="text/javascript" src="http://www.google.com/jsapi"></script>

</head>
<body style="background-color: #3b79ac;">
<!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
chromium.org/developers/how-tos/chrome-frame-getting-started -->
<!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
<header>
    <div id="header" class="header" style="width: 100%; height: 115px; margin: auto auto; text-align: center;">
        <img src="../img/logo.png" width="420px" alt="Gemster Logo" style="margin-left: -140px; z-index: 42;"/>
		<div style="font-size: 16px; color: white; margin-top: -30px; margin-left: 430px;">The Social Event Finder</div>
    </div>
</header>



<div role="main" style="width: 100%; min-width: 1000px; height: 100%; margin: auto auto; background-color: white; text-align: left;background-color: #d3d3d3;">



    <div id="container" style="margin: auto auto; width: 960px;  min-height: 1300px; overflow: overflow-x;">




        <div style="width: 640px; min-height: 840px; border-left: 1px solid #a9a9a9; border-right: 1px solid #a9a9a9; border-bottom: 1px solid #a9a9a9; float: left; margin-left: 0px;">


				
				<div id="map" style="margin-left: 0px; margin-top: 0px; width: 640px; height: 140px; padding-top: 0px; background-color: transparent;">
                </div>
				
			

            <div id="top" style="height: 484px; background-image: url(../img/event_details_top.png); background-repeat: no-repeat;">

                <div id="date" style="height: 40px; color: white; font-size: 15px; font-weight: bold; padding-top: 8px;">
                </div>
                <div id="scrollerWrapper">
                    <ul id="scroller"><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li><li><?php echo $name; ?></li></ul>
                </div>

                <div style="width: 100%; height: 280px; margin-top: 35px;">

                    <div id="picture" style="width: 280px; height: 280px; margin-left: 20px; margin-top: -10px; float: left; overflow: hidden; background-color: #c5c5c5; background-image: url(<?php echo ($pic_url . '?type=large'); ?>)">

                        <img id="featuredIcon" src="../img/featured.png" style="width: 96px; margin-left: 184px;"/>
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

                <div id="goodies" style="margin-top: 0px;">
                    <div id="special" style="border: 0px solid red; width: 90%; margin-left: 40px; height: 42px;">
                        <img src="../img/goodiesGift.png" style="width: 42px; float: left; margin-right: 12px;" />
                        <div id="specialText" style=" padding-top: 8px;"></div>
                    </div>
                    <div id="ticket" style="border: 0px solid red; width: 90%; margin-left: 40px; height: 42px;">
                        <img src="../img/ticket.png" style="width: 38px; float: left; margin-left: 4px; margin-top: 8px; margin-right: 12px;" />
                        <div style="padding-top: 10px;"><a id="ticketLink" href="#" target="_blank" style="text-decoration: underline;" >Buy ticket directly from provider</a></div>
                    </div>

                    <hr style="width: 89%; margin-left: 35px;" />
                </div>
                <div id="description" style="width: 90%; min-height: 280px; padding-left: 40px; display: none;">

                </div>

            </div>

            <div id="bottom" style="height: 38px; background-image: url(../img/event_details_bottom.png);">

            </div>

        </div>

        <div id="scrollingDiv" style="width: 300px; height: 840px; margin-top: 5px;  float: right;  padding-top: 0px;">

            <div style="width: 300px; text-align: center;">
                
				<div>

					<div>
						<img src="../img/phone.png" style="float:left; margin-left: 17px;" />
					</div>

					<div class="download-button" style="margin-top: 20px; margin-left: 30px;">
                    	<a id="button-get-the-app" href="http://itunes.apple.com/us/app/gemster/id553371725" target="_blank" class="button-get-the-app">Get the App (Free)</a>
                	</div>
				
				</div>
				
				<div>

					<div>
						<img src="../img/cal.png" style="float:left; margin-left: 10px;" />
					</div>
					<div class="download-button" style="margin-top: 20px; margin-left: 25px;">
                    	<a id="button-promote" href="../promoter/" class="button-promote">Promote an Event</a>
                	</div>
				</div>
				<div style="margin-top: -30px;">
					<img src="../img/separator.png">
				</div>

            </div>

            <div style="margin-top: 10px; margin-left: 65px; margin-bottom: 10px;">
                <span class='st_facebook_large' displayText='Facebook'></span>
                <span class='st_twitter_large' displayText='Tweet'></span>
                <span class='st_linkedin_large' displayText='LinkedIn'></span>
                <span class='st_email_large' displayText='Email'></span>
            </div>

            





            <div style="text-align: center; margin-top: 0px;">
                <iframe src="http://www.facebook.com/plugins/facepile.php?
                    app_id=299292173427947" scrolling="no" frameborder="0" style="border:none;
                    overflow:hidden; width:300px; height: 100px;" allowTransparency="true"></iframe>

                 <iframe src="//www.facebook.com/plugins/like.php?href=https%3A%2F%2Fwww.facebook.com%2Fpages%2FGemster%2F395304430527422
                        &amp;send=false&amp;layout=standard&amp;width=200&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;
                        font&amp;height=35&amp;appId=134120316726672"scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:300px; height:42px; margin-top: -20px;" allowTransparency="true"></iframe>


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
                <a class="footer-link" href="../press/release.pdf">Press</a>
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

    $("document").ready(function() {

        $('#featuredIcon').hide();
        $('#special').hide();
        $('#ticket').hide();
        $('#goodies').hide();

        $('#img').fadeIn();

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

        var language = window.navigator.userLanguage || window.navigator.language;
        var latitude = '40.7433586';
        var longitude = '-73.972406';

        if (google.loader.ClientLocation != null && google.loader.ClientLocation.latitude != null) {

            latitude = google.loader.ClientLocation.latitude;
            longitude = google.loader.ClientLocation.longitude;
        }



        $.ajax({

            url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://api.gemsterapp.com/calendar?is_chaman=true&eventID=' + getParameterByName('eid') + '&access_token=BAAEQNGOuZAOsBACXY34ZCeKSaYMzneAXD46mkV577t5Dvog7mAUZC66ceUs7y83d5THQKTJkUwh5cZCplSFxgizKkB5lx8i3ZAQeoQlTttjc5RUDH7mkUwyOq9mUpJrcZD' + '&timezone_offset=' + '-240' + '&locale=' + language.replace('-', '_'))
        }).done(function(data) {

            var e = data.records[0];

            var vc = e.venue_category;


            if (vc != null && vc != undefined) {

                if (vc.length > 35) {

                    vc = vc.substr(0, 32) + '...';
                }
            } else {

                vc = 'unknown category';
            }

            if (e.featured != null) {

                $('#featuredIcon').show();

                if (e.offer_title != null && e.offer_title != '') {
                    $('#goodies').show();
                    $('#specialText').html(e.offer_title + ' -- ' + e.offer_description);
                    $('#special').show();
                }

                if (e.ticket_link != null && e.ticket_link != '') {
                    $('#goodies').show();
                    $('#ticketLink').attr('href', e.ticket_link);
                    $('#ticket').show();
                }
            }


            if (e.latitude && e.latitude != null) {
				
				if (e.address == null) {
					$.ajax({
						url : '../php/proxy.php?proxy_url=' + encodeURIComponent('http://maps.google.com/maps/api/geocode/json?sensor=true&latlng=' + e.latitude + ',' + e.longitude)
					}).done(function(data) {

							var add = data.results[0].formatted_address;

							if (add.length > 44) {

								add = add.substring(0, 41) + '...';
							}

							$('#other').html('<div style="width: 40%; float: left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + vc + '</div>' + '<div style="width: 60%; float: left; text-align: right;">' + add  + ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>');
							$('#other').fadeIn();
					});
				} else {
					var add = e.address;

					if (add.length > 44) {

						add = add.substring(0, 41) + '...';
					}
					$('#other').html('<div style="width: 40%; float: left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + vc + '</div>' + '<div style="width: 60%; float: left; text-align: right;">' + add  + ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>');
					$('#other').fadeIn();
				}

                $('#map').html('<img src="http://maps.googleapis.com/maps/api/staticmap?center=' + e.latitude + ',' + e.longitude + '&zoom=13&size=640x140&maptype=roadmap&markers=color:red%7Ccolor:red%7Clabel:%7C' + e.latitude + ',' + e.longitude + '&sensor=false" style="width: 640px; height:140px;" />');

                setTimeout(function() {

                    $('#map').fadeIn();
                }, 100);


            } else {

                $('#map').html('<img src="../img/nomap.png" style="width: 280px; height:280px;margin-top: 0px; padding-top: 0px;" />');

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

                score += '<div style="float: left; padding-top: 50px;"><img style="width: 54px; height: 45px;" src="../img/' + img + '" alt="score" /></div>';
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

    var _gaq = [
            ['_setAccount', 'UA-33038234-1'],
            ['_trackPageview']
        ];
        (function (d, t) {
            var g = d.createElement(t), s = d.getElementsByTagName(t)[0];
            g.src = ('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g, s)
        }(document, 'script'));


</script>

</body>
</html>