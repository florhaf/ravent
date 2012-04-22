package com.chaman.model;

import java.util.ArrayList;

import com.chaman.util.JSON;

public class Picture extends Model {

	String first_name;
	String last_name;
	String picture; // of the user
	String uid;
	String time;
	String url;
	
	public Picture(String accessToken, Post p) {
		
		this.uid = JSON.GetValueFor("id", p.getFrom());
		
		User u = (User) User.GetFacebookUserInfo(accessToken, this.uid).get(0);
		
		this.first_name = u.getFirst_name();
		this.last_name = u.getLast_name();
		this.picture = u.getPicture();
		this.time = p.getCreated_time();		
		this.url = p.getPicture();
	}
	
	public static ArrayList<Model> Get(String accessToken, String eventID) {

		ArrayList<Model> feed = Post.Get(accessToken, eventID);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Model m : feed) {
			
			Post p = (Post)m;
			
			if (p.getType().equals("photo")) {
				
				Picture pic = new Picture(accessToken, p);
				result.add(pic);
			}
		}
 	
		return result;
	}
	
	public String getFirst_name() {
		return this.first_name;
	}
	
	public String getLast_name() {
		return this.last_name;
	}
	
	public String getPicture() {
		return this.picture;
	}
	
	public String getTime() {
		return this.time;
	}
	
	public String getUrl() {
		return this.url;
	}
}
