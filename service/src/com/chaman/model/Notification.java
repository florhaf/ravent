package com.chaman.model;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import com.chaman.dao.Dao;
import com.chaman.util.JSON;
import com.googlecode.objectify.Query;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.exception.FacebookOAuthException;
import com.restfb.types.FacebookType;

public class Notification  extends Model {

	@Facebook
	String recipient_id;
	@Facebook
	String template;
	@Facebook
	String href;
	
	public static void NotifyOneUser(String accessToken, String userID, String template, String href) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken); // globalviaduct app access token
		try {	
			client.publish(userID + "/notifications", FacebookType.class, Parameter.with("template", template), Parameter.with("href", href));
		} catch (Exception ex) {
			client.publish(userID + "/notifications", FacebookType.class, Parameter.with("template", template), Parameter.with("href", href));
		}
	}
	
	public static void NotifySeveralUsers(String accessToken, ArrayList<Notification> notif_to_send) {
		
		for (Notification notif: notif_to_send)
		{
			NotifyOneUser(accessToken, notif.recipient_id, notif.template, notif.href); // globalviaduct app access token
		}
	}
	
	public static void Notify_access_exp() {
		
		Dao dao = new Dao();
		Query<User> quser = dao.ofy().query(User.class);
		
		double nb_reminder = 0;
		double nb_access_exp = 0;
		double nb_error = 0;
		
		String app_access = 		get_app_token();
		
		for (User u: quser)
		{ // TODO: Thread
			FacebookClient client 	= new DefaultFacebookClient(u.access_token);
			String userQuery 		= "SELECT current_location FROM user WHERE uid  = " + u.uid;
			try {
				
				try {
					
					client.executeQuery(userQuery, User.class);
					
					if (u.current_location != null) {
					
						String query 			= "SELECT name, location FROM page WHERE page_id = " + JSON.GetValueFor("id", u.current_location);
						List<Venue> fbplace 	= client.executeQuery(query, Venue.class);
						
						String name = fbplace.get(0).name;
						//String latitude	= JSON.GetValueFor("latitude", fbplace.get(0).location); // to use to send list of events later
						//String longitude = JSON.GetValueFor("longitude", fbplace.get(0).location);
						
						NotifyOneUser(app_access, Long.toString(u.uid), "We found some good events for you around " + name + " Check them out!", "");
					} else {
						NotifyOneUser(app_access, Long.toString(u.uid), "We found some good events for you. Check them out!", "");
					}
					nb_reminder++;
					
				} catch (FacebookOAuthException ex) {
				    
					// if user access token not expired
					if (ex.getErrorType().equals("190"))
						NotifyOneUser(app_access, Long.toString(u.uid), "We have been missing you since the last time you used Gemster. Check out what's going on near you and give us your feedback!", "");
					nb_access_exp++;
				}
				
			} catch (Exception ex) {
				nb_error++;
			}

		}
		
		log.severe("Notifications sent: " + nb_reminder + " reminder & " + nb_access_exp + " access expired & " + nb_error + " errors");
	}
	
	public static String get_app_token() {
	
		URL url;
	    HttpURLConnection connection = null;  
		String app_access =null;
		
	    try {
		     //Create connection
		      url = new URL("https://graph.facebook.com/oauth/access_token?client_id=299292173427947&client_secret=d894ccb29b3fbba3591256dad5d0c1c5&grant_type=client_credentials");
		      connection = (HttpURLConnection)url.openConnection();
		      connection.setRequestMethod("GET");
		      connection.setRequestProperty("Content-Type", 
		           "text/plain");
		      connection.setUseCaches (false);
		      connection.setDoInput(true);
		      connection.setDoOutput(true);
		      connection.connect();
		      InputStream is = connection.getInputStream();
		      BufferedReader rd = new BufferedReader(new InputStreamReader(is));
		      app_access = rd.readLine().substring(13);
	    } catch (Exception ex1) {}
	    finally {
	    	connection.disconnect(); 
	    }
	    
	    return app_access;
	}
}
