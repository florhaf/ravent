package com.chaman.model;

import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

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
	
	public static ArrayList<Model> Get(String accessToken, String eventID) throws FacebookException {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		Connection<Post> myFeed = client.fetchConnection(eventID + "/feed", Post.class);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Post p : myFeed.getData()) {
			
			result.add(p);
		}
 	
		return result;
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
		client.publish(eventID + "/feed", FacebookType.class, BinaryAttachment.with("Ravent", data), Parameter.with("message", message));
	}
	
	public static void ShareEvent(String accessToken, String friendID, String eventID) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		String msg = "I'm sharing";
		
		String query 				= "SELECT uid FROM event_member WHERE eid = " + eventID + " AND uid = " + friendID;
		List<Attending> friend 	= client.executeQuery(query, Attending.class);
		
		if (friend.isEmpty()) { // could also just check the exception return code of the FB call to avoid the fetch
			
			client.publish(eventID + "/invited/", FacebookType.class, Parameter.with("users", friendID));
			msg = msg + " and inviting you to";
		}
		
		client.publish(friendID + "/feed", FacebookType.class, Parameter.with("message", msg + " this event " + eventID + (msg.length() > 12 ? "" : " with you") )); //add link;
	}
	
	public String getType() {
		return this.type;
	}
	
	public String getFrom() {
		return this.from;
	}
	
	public String getPicture() {
		return this.picture;
	}
	
	public String getMessage() {
		return this.message;
	}
	
	public String getCreated_time() {
		return this.created_time;
	}

}
