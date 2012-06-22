package com.chaman.model;

import java.util.ArrayList;

import com.chaman.util.JSON;
import com.restfb.Connection;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.types.FacebookType;

public class Comment extends Model {

	String first_name; // TODO: Change to name
	String last_name;
	String picture_user; // of the user
	String profileID;
	String time;
	String message;
	String picture;
	
	public Comment(String accessToken, Post p) {
		
		this.profileID = JSON.GetValueFor("id", p.getFrom());
		
		ArrayList<Model> profiles = Profile.GetFacebookProfileInfo(accessToken, this.profileID);
		
		if (profiles != null) {
			
			Profile profile = (Profile) profiles.get(0);
			
			this.first_name = profile.getName();
			this.picture_user = profile.getPic();
		}
		
		this.time = p.getCreated_time();		
		this.message = p.getMessage();
		this.picture = p.getPicture();
	}
	
	public static ArrayList<Model> Get(String accessToken, String eventID) {

		Connection<Post> feed = Post.Get(accessToken, eventID);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Post p : feed.getData()) {
						
			if (p.getType().equals("status") || p.getType().equals("photo")) {
				
				Comment c = new Comment(accessToken, p);
				result.add(c);
			}
		} 
 	
		return result;
	}
	
	public static void Put(String accessToken, String eventID, String message) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		
		client.publish(eventID + "/feed", FacebookType.class, Parameter.with("message", message));
	}
	
	public String getFirst_name() {
		return this.first_name;
	}
	
	public String getLast_name() {
		return this.last_name;
	}
	
	public String getPicture_user() {
		return this.picture_user;
	}
	
	public String getTime() {
		return this.time;
	}
	
	public String getMessage() {
		return this.message;
	}

	public String getPicture() {
		return picture;
	}	
}