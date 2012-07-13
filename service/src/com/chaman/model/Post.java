package com.chaman.model;

import java.io.InputStream;
import java.io.ByteArrayInputStream;

import com.restfb.BinaryAttachment;
import com.restfb.Connection;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.exception.FacebookException;
import com.restfb.types.FacebookType;

public class Post  extends Model {

	@Facebook
	String from;
	@Facebook
	String type; // { photo || status }
	@Facebook
	String picture;
	@Facebook
	String message;
	@Facebook
	String created_time;
	
	public static Connection<Post> Get(String accessToken, String eventID) throws FacebookException {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		try {
			return client.fetchConnection(eventID + "/feed", Post.class);
		} catch (Exception ex ) { //retry
			return client.fetchConnection(eventID + "/feed", Post.class);
		}
	}
	
	public static void WallPost(String accessToken, String userID, String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		//TODO: add reference to ravent
		client.publish(userID + "/feed", FacebookType.class, Parameter.with("message", message));
	}
	
	public static void FriendWallPost(String accessToken, String friendID, String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		//TODO: add reference to ravent
		client.publish(friendID + "/feed", FacebookType.class, Parameter.with("message", message));
	}

	public static void FriendWallPostWithAttachment(String accessToken, String friendID, String attachment, String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		InputStream data = new ByteArrayInputStream(attachment.getBytes());
		//TODO: add reference to ravent
		client.publish(friendID + "/feed", FacebookType.class, BinaryAttachment.with("Ravent", data), Parameter.with("message", message));
		
	}
	
	public static void EventPost(String accessToken, String userID, String eventID, String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		//TODO: add reference to ravent
		client.publish(eventID + "/feed", FacebookType.class, Parameter.with("message", message));
	}
	
	public static void EventPostWithAttachment(String accessToken, String userID, String eventID, String attachment,String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		InputStream data = new ByteArrayInputStream(attachment.getBytes());
		//TODO: add reference to ravent
		client.publish(eventID + "/feed", FacebookType.class, BinaryAttachment.with("IMG.jpg", data), Parameter.with("type", "photo"));
	}
	
	public static String ShareEvent(String accessToken, String friendID, String eventID) throws FacebookException {

		FacebookClient client	= new DefaultFacebookClient(accessToken);
		
		try {
			
			client.publish(eventID + "/invited/", Boolean.class, Parameter.with("users", friendID));
		}
		catch (Exception ex ) {
			
			client.publish(friendID + "/feed", FacebookType.class, Parameter.with("message", "I'm inviting you to an event"), Parameter.with("link", "http://facebook.com/" + eventID)); //add link;
			return "Your friend cannot be invited directly to this event. A message has been posted on your friend's Timeline."; //TODO: do we want the user to choose if he wants to write on his friend time line?
		}
		
		return null;
	}
	
	public String getType() {
		return this.type;
	}
	
	public String getFrom() {
		return this.from;
	}
	
	public String getPicture() {
		
		if (this.picture != null) {
			
			this.picture = this.picture.substring(0, this.picture.length() - 5).concat("n.jpg");
		}

		return this.picture;
	}
	
	public String getMessage() {
		return this.message;
	}
	
	public String getCreated_time() {
		return this.created_time;
	}

}
