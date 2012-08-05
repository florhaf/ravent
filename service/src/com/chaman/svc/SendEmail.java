package com.chaman.svc;

import java.util.Properties;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.restlet.data.Form;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;


public class SendEmail  extends ServerResource {

	@Get
	public Response handlePost(Form webForm) { 
	   
	   Response result = new Response();
		
		try {

			String email = getQuery().getValues("email");
			
			Properties props = new Properties();
	        Session session = Session.getDefaultInstance(props, null);

	        String msgBody = "Welcome to GEMSTER! \n\nYou are one click away to change the way you look for events arround you: http://m.gemsterapp.com \n\nEnjoy,\nGemster's Team";

        		Message msg = new MimeMessage(session);
	            msg.setFrom(new InternetAddress("it@gemsterapp.com", "Contact"));
	            msg.addRecipient(Message.RecipientType.TO,
	                             new InternetAddress(email, "Future Member!"));
	            msg.addRecipient(Message.RecipientType.BCC,
                        new InternetAddress("contact@gemsterapp.com", "Gemster Contact!"));
	            msg.setSubject("[GEMSTER] - Get the app");
	            msg.setText(msgBody);
	            Transport.send(msg);
	        
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}