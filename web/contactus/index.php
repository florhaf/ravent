<?php

session_name("contact-us-form");
session_start();


$_SESSION['n1'] = rand(1,20);
$_SESSION['n2'] = rand(1,20);
$_SESSION['expect'] = $_SESSION['n1']+$_SESSION['n2'];


$str='';
if($_SESSION['errStr'])
{
	$str='<div class="error">'.$_SESSION['errStr'].'</div>';
unset($_SESSION['errStr']);
}

$success='';
if($_SESSION['sent'])
{
$success='<h1>Thank you!</h1>';

$css='<style type="text/css">#contact-form{display:none;}</style>';

unset($_SESSION['sent']);
}
?>
<!doctype html>
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!-- Consider adding a manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
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

    <link rel="stylesheet" type="text/css" href="../css/jqtransform.css" />
    <link rel="stylesheet" type="text/css" href="../css/validationEngine.jquery.css" />
    <link rel="stylesheet" type="text/css" href="../css/form.css" />

    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>

    <script type="text/javascript" src="../js/jqtransformplugin/jquery.jqtransform.js"></script>
    <script type="text/javascript" src="../js/formValidator/jquery.validationEngine.js"></script>

    <script type="text/javascript" src="script.js"></script>

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

<div role="main" style="width: 100%; min-width: 1000px; height: 100%; margin: auto auto; background-color: white; text-align: left;background-color: #d3d3d3;"">
    <div style="width: 600px; margin: auto auto; padding: 10px;">

        <div id="main-container" style="margin-top: 10px;">

            <div id="form-container">
                <h1>Contact Us</h1>
                <h2>Drop us a line and we will get back to you</h2>

                <form id="contact-form" name="contact-form" method="post" action="submit.php">
                    <table width="100%" border="0" cellspacing="0" cellpadding="5">
                        <tr>
                            <td width="15%"><label for="name">Name</label></td>
                            <td width="70%"><input type="text" class="validate[required,custom[onlyLetter]]" name="name" id="name" value="<?=$_SESSION['post']['name']?>" /></td>
                            <td width="15%" id="errOffset">&nbsp;</td>
                        </tr>
                        <tr>
                            <td><label for="email">Email</label></td>
                            <td><input type="text" class="validate[required,custom[email]]" name="email" id="email" value="<?=$_SESSION['post']['email']?>" /></td>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td><label for="subject">Subject</label></td>
                            <td><select name="subject" id="subject">
                                <option value="" selected="selected"> - Choose -</option>
                                <option value="Question">Question</option>
                                <option value="Business proposal">Business proposal</option>
                                <option value="Advertisement">Advertising</option>
                                <option value="Complaint">Complaint</option>
                            </select>          </td>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td valign="top"><label for="message">Message</label></td>
                            <td><textarea name="message" id="message" class="validate[required]" cols="85" rows="10"><?=$_SESSION['post']['message']?></textarea></td>
                            <td valign="top">&nbsp;</td>
                        </tr>
                        <tr>
                            <td><label for="captcha"><?=$_SESSION['n1']?> + <?=$_SESSION['n2']?> =</label></td>
                            <td><input type="text" class="validate[required,custom[onlyNumber]]" name="captcha" id="captcha" /></td>
                            <td valign="top">&nbsp;</td>
                        </tr>
                        <tr>
                            <td valign="top">&nbsp;</td>
                            <td colspan="2"><input type="submit" name="button" id="button" value="Submit" />
                                <input type="reset" name="button2" id="button2" value="Reset" />

                                <?=$str?>          <img id="loading" src="img/ajax-load.gif" width="16" height="16" alt="loading" /></td>
                        </tr>
                    </table>
                </form>
                <?=$success?>
            </div>

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

    $("document").ready(function() {


    });

    $("#header").click(function() {

        window.location = "../";
    });


</script>

<!-- Asynchronous Google Analytics snippet. Change UA-XXXXX-X to be your site's ID.
mathiasbynens.be/notes/async-analytics-snippet -->
<script>
    var _gaq=[['_setAccount','UA-XXXXX-X'],['_trackPageview']];
    (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
        g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
        s.parentNode.insertBefore(g,s)}(document,'script'));
</script>
</body>
</html>