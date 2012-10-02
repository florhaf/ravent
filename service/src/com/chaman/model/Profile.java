package com.chaman.model;

import java.util.ArrayList;
import java.util.List;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;

public class Profile extends Model {

	@Facebook
	String page_id; //used for page admin
	@Facebook
	String uid; //used for page admin
	@Facebook
	String name;
	@Facebook
	String pic;
	
	public Profile() {
		
		super();
	}
	
	public static ArrayList<Model> GetFacebookProfileInfo(String accessToken, String profileID) {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "name, pic";
		String userQuery 		= "SELECT " + properties + " FROM profile WHERE id  = " + profileID;
		
		List<Profile> profiles 		= client.executeQuery(userQuery, Profile.class);
		
		if (profiles != null) {

			Profile p = profiles.get(0);
			result.add(p);
		}
 	
		return result;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPic() {
		return pic;
	}

	public void setPic(String pic) {
		this.pic = pic;
	}

	public void setPage_id(String page_id) {
		this.page_id = page_id;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}
}
