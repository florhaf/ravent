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
   <meta property="og:title" content="<?php echo $_GET['name']; ?>" />
   <meta property="og:description" content="<?php echo $_GET['location']; ?>" />
   <meta property="og:image" content="<?php echo $_GET['picture']; ?>" />
   <meta property="og:url" content="http://gemsterapp.com/facebook/event_page.php?eid=<?php echo $_GET['eid']; ?>&name=<?php echo $_GET['name']; ?>&location=<?php echo $_GET['location']; ?>&picture=<?php echo $_GET['picture']; ?>" />

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

    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>

</head>
<body style="background-color: #3b79ac;">
<!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
chromium.org/developers/how-tos/chrome-frame-getting-started -->
<!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
<header>
    <div id="header" class="header" style="width: 100%; height: 115px; margin: auto auto; text-align: center;">
        <img src="../img/logo.png" width="420px" alt="Gemster Logo" style="margin:auto auto; z-index: 42;"/>
    </div>
</header>

<div role="main" style="width: 100%; min-width: 1000px; height: 100%; margin: auto auto; background-color: white; text-align: left;background-color: #d3d3d3;">

    <div style="width: 640px; height:767px; margin: auto auto;background-image: url(../img/event_details.png); background-repeat: no-repeat; border-left: 1px solid #a9a9a9; border-right: 1px solid #a9a9a9;">

        <div id="name" style="width: 100%; height: 70px; font-size: 50px; padding-left: 20px;">

        </div>

        <div id="top" style="border: 0px solid green; width: 100%; height: 280px; margin-top: 35px;">

            <div id="picture" style="width: 280px; height: 280px; margin-left: 20px; float: left; overflow: hidden;">

            </div>

            <div id="location" style="width: 270px; height: 90px; margin-left: 30px; float: left; font-size: 25px; text-align: center;">

            </div>

            <div id="score" style="border: 1px solid green; width: 270px; height: 90px; margin-left: 30px; float: left;">

            </div>

            <div id="ratio" style="border: 1px solid green; width: 270px; height: 90px; margin-left: 30px; float: left;">

            </div>

        </div>

        <div id="middle" style="border: 1px solid green; width: 100%; height: 40px; margin-top: 10px;">

        </div>

        <div id="bottom" style="border: 1px solid green; width: 100%; height: 280px; margin-top: 10px;">

        </div>


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

$.urlParam = function(name){
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (!results)
    {
        return 0;
    }
    return results[1] || 0;
}

    $("document").ready(function() {

        var name = $.urlParam('name');
        var location = $.urlParam('location');
        var picture = $.urlParam('picture');

        $('#name').html(decodeURIComponent(name));
        $('#location').html(decodeURIComponent(location));
        $('#picture').html('<img src="' + decodeURIComponent(picture) + '" style="width: 100%;" />');

    });

    $("#header").click(function() {

        window.location = "../";
    });


</script>

</body>
</html>