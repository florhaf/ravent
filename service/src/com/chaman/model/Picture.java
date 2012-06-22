package com.chaman.model;

import java.util.ArrayList;

import com.chaman.util.JSON;
import com.restfb.Connection;

public class Picture extends Model {

	String first_name; // TODO: Change to name
	String last_name;
	String picture_user; // of the user
	String profileID;
	String time;
	String url;
	String picture;
	
	public Picture(String accessToken, Post p) {
		
		this.profileID = JSON.GetValueFor("id", p.getFrom());
		
		ArrayList<Model> profiles = Profile.GetFacebookProfileInfo(accessToken, this.profileID);
		
		if (profiles != null) {
			
			Profile profile = (Profile) profiles.get(0);
			this.first_name = profile.getName();
			this.picture_user = profile.getPic();
		}
		
		this.time = p.getCreated_time();		
		this.url = p.getPicture();
		this.picture = p.getPicture();
	}
	
	public static ArrayList<Model> Get(String accessToken, String eventID) {

		Connection<Post> feed = Post.Get(accessToken, eventID);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Post p : feed.getData()) {

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

	public String getPicture_user() {
		return picture_user;
	}

	public void setPicture_user(String picture_user) {
		this.picture_user = picture_user;
	}
}
