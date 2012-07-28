<?php

/* config start */

$emailAddress = $_GET['to'];

/* config end */


require "phpmailer/class.phpmailer.php";

session_name("contact-us-form");
session_start();




$msg=
'Name:	'.$_POST['name'].'<br />
Email:	'.$_POST['email'].'<br />
IP:	'.$_SERVER['REMOTE_ADDR'].'<br /><br />

Message:<br /><br />

'.nl2br($_POST['message']).'

';


$mail = new PHPMailer();
$mail->IsMail();

$mail->AddReplyTo($_POST['email'], $_POST['name']);
$mail->AddAddress($emailAddress);
$mail->SetFrom($_POST['email'], $_POST['name']);
$mail->Subject = mb_strtolower($_POST['subject']);

$mail->MsgHTML($msg);

$mail->Send();


?>
