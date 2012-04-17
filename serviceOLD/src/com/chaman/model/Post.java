package com.chaman.model;

import java.util.ArrayList;

import com.restfb.Connection;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

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
