package com.chaman.model;

import java.util.ArrayList;

import com.chaman.util.JSON;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.types.FacebookType;

public class Comment extends Model {

	String first_name;
	String last_name;
	String picture_user; // of the user
	String uid;
	String time;
	String message;
	
	public Comment(String accessToken, Post p) {
		
		this.uid = JSON.GetValueFor("id", p.getFrom());
		
		ArrayList<Model> users = User.GetFacebookUserInfo(accessToken, this.uid);
		
		if (users != null) {
			
			User u = (User) users.get(0);
			
			this.first_name = u.getFirst_name();
			this.last_name = u.getLast_name();
			this.picture_user = u.getPicture();
		}
		
		this.time = p.getCreated_time();		
		this.message = p.getMessage();
	}
	
	public static ArrayList<Model> Get(String accessToken, String eventID) {

		ArrayList<Model> feed = Post.Get(accessToken, eventID);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Model m : feed) {
			
			Post p = (Post)m;
			
			if (p.getType().equals("status")) {
				
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
}
