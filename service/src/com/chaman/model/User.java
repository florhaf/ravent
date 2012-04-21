package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;
import javax.persistence.Transient;
import javax.persistence.Entity;

import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.json.JsonObject;

@Entity
public class User extends Model {

	@Id
	@Facebook
	long uid;
	@Facebook
	String first_name;
	@Facebook
	String last_name;
	@Facebook
	String pic;
	@Facebook
	String email;
	@Facebook
	String birthday_date;
	@Facebook
	String sex;
	@Facebook
	String relationship_status;
	/* Need to capture the time spent on the app somehow / need class for datastore with less variables*/
	
	@Transient
	String picture;
	String access_token;

	int nb_of_events;
	int nb_of_followers;
	int nb_of_following;
	
	float searchRadius;
	
	public User() {
		
		super();
		
		searchRadius = 30;
	}
	
	
	static {
		try {
			ObjectifyService.register(User.class);
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}
	
	public static User Get(long userID) {
		
		return new User();
	}
	
	public static ArrayList<Model> Get(String accessToken, String userID) {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "uid, first_name, last_name, pic, email, sex, birthday_date, relationship_status";
		String userQuery 		= "SELECT " + properties + " FROM user WHERE uid  = " + userID;
		
		List<User> users 		= client.executeQuery(userQuery, User.class);
		
		String eventQuery = "SELECT eid from event_member where uid = ";
		
		Dao dao = new Dao();
		
		for (User u : users) {
			
			u.picture = u.pic;
			
			List<JsonObject> event_member = client.executeQuery(eventQuery + u.uid, JsonObject.class);
			
			u.nb_of_events = event_member.size();
			
			Query<Following> qfollowings = dao.ofy().query(Following.class);
        	qfollowings.filter("userID", u.uid);
        	u.nb_of_following = qfollowings.count();
        	
        	Query<Following> qfollowers = dao.ofy().query(Following.class);
        	qfollowers.filter("friendID", u.uid);
        	u.nb_of_followers = qfollowers.count();
			
        	u.access_token = accessToken;
        	dao.ofy().put(u); /*add the user to the datastore*/ /*find a solution to store friends*/
        	
			result.add(u);
		}
 	
		return result;
	}
	
	public static ArrayList<Model> GetMultiples(String accessToken, ArrayList<Model> dbUsers) {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		if (dbUsers.size() == 0) {
			
			return result;
		}
		
		String strUids = "";
		
		for (int i = 0; i < dbUsers.size(); i++) {
			
			strUids += "uid = " + ((User)dbUsers.get(i)).uid;
			
			if (i < dbUsers.size() - 1) {
				
				strUids += " OR ";
			}
		}
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "uid, first_name, last_name, pic, email, sex, birthday_date, relationship_status";
		String query 			= "SELECT " + properties + " FROM user WHERE " + strUids + " ORDER BY last_name";
		List<User> users 		= client.executeQuery(query, User.class);
		
		String eventQuery = "SELECT eid from event_member where uid = ";

		Dao dao = new Dao();
		
		for (User u : users) {
			
			u.picture = u.pic;
			
			List<JsonObject> event_member = client.executeQuery(eventQuery + u.uid, JsonObject.class);
			
			u.nb_of_events = event_member.size();
			
			User dbu = User.getUserByUID(u.uid, dbUsers);
			
			if (dbu != null) {
				
				u.nb_of_followers = dbu.nb_of_followers;
				u.nb_of_following = dbu.nb_of_following;
				
				u.access_token = accessToken;
	        	
			}
			dao.ofy().put(u);
			result.add(u);
		}
 	
		return result;
	}
	
	public static User getUserByUID(long uid, ArrayList<Model> users) {
		
		User result = null;
		
		for (Model m : users) {
			
			User u = (User)m;
			
			if (u.uid == uid) {
				
				result = u;
				break;
			}
		}
		
		return result;
	}
	
	public long getUid() {
		
		return this.uid;
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
	
	public String getEmail() {
		
		return this.email;
	}
	
	public String getBirthday_date() {
		
		return this.birthday_date;
	}
	
	public String getSex() {
		
		return this.sex;
	}
	
	public String getRelationship_status() {
		
		return this.relationship_status;
	}
	
	public float getSearchRadius() {
		
		return this.searchRadius;
	}
	
	public int getNb_of_events() {
		
		return this.nb_of_events;
	}
	
	public int getNb_of_followers() {
		
		return this.nb_of_followers;
	}

	public int getNb_of_following() {
	
		return this.nb_of_following;
	}
	
	public void setNb_of_events(int nb_of_events) {
		
		this.nb_of_events = nb_of_events;
	}
	
	public void setNb_of_followers(int nb_of_followers) {
		
		this.nb_of_followers = nb_of_followers;
	}

	public void setNb_of_following(int nb_of_following) {
	
		this.nb_of_following = nb_of_following;
	}
}
