package com.chaman.model;

import java.util.ArrayList;
import com.restfb.Connection;

public class Picture extends Model {

	String picture;
	
	public Picture(Post p) {
		
		this.picture = p.getPicture();
	}
	
	public static ArrayList<Model> Get(String accessToken, String eventID) {

		Connection<Post> feed = Post.Get(accessToken, eventID);
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		for (Post p : feed.getData()) {

			if (p.getType().equals("photo")) {
				
				Picture pic = new Picture(p);
				result.add(pic);
			}
		}
 	
		return result;
	}
	
	public String getPicture() {
		return this.picture;
	}
}
