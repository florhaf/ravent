package com.chaman.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ArrayBlockingQueue;

import javax.persistence.Id;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;

import com.chaman.dao.Dao;
import com.chaman.util.EventTools;
import com.chaman.util.MyThreadManager;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;
import com.googlecode.objectify.annotation.NotSaved;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.json.JsonObject;
import com.google.appengine.api.memcache.AsyncMemcacheService;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

@Entity
@Unindexed
public class User extends Model implements Serializable, Runnable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4211657780516168572L;
	
	@Id
	@Facebook
	long uid;
	@NotSaved
	@Facebook
	String first_name;
	@NotSaved
	@Facebook
	String last_name;
	@NotSaved
	@Facebook
	String pic;
	@NotSaved
	@Facebook
	String email;
	@NotSaved
	@Facebook
	String birthday_date;
	@NotSaved
	@Facebook
	String sex;
	@NotSaved
	@Facebook
	String relationship_status;
	@NotSaved
	@Facebook
	String current_location;
	
	@NotSaved
	String picture;
	String access_token;

	@NotSaved
	int nb_of_events;
	int nb_of_followers;
	int nb_of_following;
	
	@NotSaved
	MyThreadManager<User> tm;
	@NotSaved
	ArrayList<User> dbUsers;
	@NotSaved
	FacebookClient client = null;
	@NotSaved
	Map<Long, Object> map_cache;
	
	public User() {
		
		super();
	}
	
	
	public User(String accessToken, String userID) {
		
		this.access_token = accessToken;
		this.uid = Long.valueOf(userID);
		this.nb_of_followers = -1;
		this.nb_of_following = -1;
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
	
	public static ArrayList<Model> Get(String accessToken, String userID, String appuser) {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "uid, first_name, last_name, pic";
		String userQuery 		= "SELECT " + properties + " FROM user WHERE uid  = " + userID;
		
		List<User> users 		= client.executeQuery(userQuery, User.class);
		
		String eventQuery = "SELECT eid from event_member where uid = ";
		
		Dao dao = new Dao();
		
		User ucache;

	    MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		
		if (users != null) {
			
			User u = (User) users.get(0);
			
			u.picture = u.pic;
			
			//Prepare a timestamp to filter the facebook DB on the upcoming events
			DateTimeZone PST = DateTimeZone.forID("America/Los_Angeles");
			DateTime now = new DateTime(PST);
			now.plusMinutes(PST.getOffset(now));
			String TAS = String.valueOf(now.getMillis() / 1000);
			
			//TODO: Remove start_time		
			List<JsonObject> event_member = client.executeQuery(eventQuery + u.uid + " AND start_time > " + TAS, JsonObject.class);
			
			u.nb_of_events = event_member.size();
			
    	    ucache = (User) syncCache.get(u.uid); // read from User cache
    	    if (ucache == null || ucache.nb_of_following == -1) {

    	    	Query<Following> qfollowings = dao.ofy().query(Following.class);
    	    	qfollowings.filter("userID", u.uid);
    	    	u.nb_of_following = qfollowings.count();
        	
    	    	Query<Following> qfollowers = dao.ofy().query(Following.class);
    	    	qfollowers.filter("friendID", u.uid);
    	    	u.nb_of_followers = qfollowers.count();
    	    	u.access_token = accessToken;
    	    	if (appuser!= null && appuser.equals("yes")) {dao.ofy().put(u);} //add the user to the data store
    	    	syncCache.put(u.uid, u, null); // populate User cache
    	    	
    	    } else {
    	    	
    	    	u.nb_of_following = ucache.nb_of_following;
    	    	u.nb_of_followers = ucache.nb_of_followers;
    	    }
        	
			result.add(u);
		}
 	
		return result;
	}
	
	public static ArrayList<Model> GetFacebookUserInfo(String accessToken, String userID) {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "uid, first_name, last_name, pic";
		String userQuery 		= "SELECT " + properties + " FROM user WHERE uid  = " + userID;
		
		List<User> users 		= client.executeQuery(userQuery, User.class);
		
		if (users != null) {
			
			User u = users.get(0);
			
			u.picture = u.pic;
	
			result.add(u);
		}
 	
		return result;
	}
	
	public static ArrayList<Model> GetMultiples(String accessToken, ArrayList<User> dbUsers) {
		
		List<Model> result = new ArrayList<Model>();
		
		if (dbUsers.size() == 0) {
			
			return (ArrayList<Model>)result;
		}
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);

		User u = new User();
		
		u.tm = new MyThreadManager<User>(u);
		
		u.dbUsers = dbUsers;
		
		u.client = client;
		
		List<Long> eventkeys = EventTools.getUserkeys(dbUsers);
		
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		u.map_cache = syncCache.getAll(eventkeys);
		
		Queue<User> q = new ArrayBlockingQueue<User>(dbUsers.size());
		q.addAll(dbUsers);
		
		result = u.tm.Process(q, 30000);
		
		return (ArrayList<Model>)result;
	}
	
	@Override
	public void run() {
		
		try {

			//Prepare a timestamp to filter the facebook DB on the upcoming events
			DateTimeZone PST = DateTimeZone.forID("America/Los_Angeles");
			DateTime now = new DateTime(PST);
			now.plusMinutes(PST.getOffset(now));
			String TAS = String.valueOf(now.getMillis() / 1000);
			
			AsyncMemcacheService asyncCache = MemcacheServiceFactory.getAsyncMemcacheService();
			 
			String eventQuery = "SELECT eid from event_member where uid = ";
			
			User u_followed = this.tm.getIdForThread(Thread.currentThread());
			
			String properties 		= "uid, first_name, last_name, pic";
			String query 			= "SELECT " + properties + " FROM user WHERE uid = " + u_followed.uid;
			List<User> users 		= client.executeQuery(query, User.class);
			
			if (!users.isEmpty()) {
				
				User u = users.get(0);
				
				u.picture = u.pic;
				
				User ucache = null;
				
				ucache = (User) map_cache.get(u.getUid());
				
				if (ucache == null) {
					
					List<JsonObject> event_member = client.executeQuery(eventQuery + u.uid + " AND start_time > " + TAS, JsonObject.class);

					u.nb_of_events = event_member.size();
							
					User dbu = User.getUserByUID(u.uid, dbUsers);
					
					if (dbu != null) {
						
						u.nb_of_followers = dbu.nb_of_followers;
						u.nb_of_following = dbu.nb_of_following;
						asyncCache.put(u.uid, u, null); // populate User cache
					}
				} else {
					
					u.nb_of_events = ucache.nb_of_events;
					u.nb_of_followers = ucache.nb_of_followers;
					u.nb_of_following = ucache.nb_of_following;
				}
				
				this.tm.AddToResultList(u);
			}
			
		} catch (Exception ex) {
		
			log.severe(ex.toString());
		} finally {
	
			tm.threadIsDone(Thread.currentThread());
		}
	}
	
	
	public static void login(String userid, String accessToken) {
		
		try {
			
			//FacebookClient client		= new DefaultFacebookClient(accessToken);
			
			Dao dao = new Dao();
		    MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		    User user = (User) syncCache.get(Long.parseLong(userid)); // read from cache
		    if (user == null) {
		    	  user = dao.ofy().find(User.class, Long.parseLong(userid));
		      }
		    
		    // first time the User uses the app
		    if (user == null ) {
		    	dao.ofy().put(new User(accessToken, userid));
		    	//client.publish(userid + "/feed", FacebookType.class, Parameter.with("message", "Started using Gemster"), Parameter.with("link", "http://www.gemsterapp.com/"),
		    	//		Parameter.with("name", "Check it out"), Parameter.with("picture", "http://gemsterapp.com/img/app_icon.png"));
		    }
		} catch (Exception ex) {log.severe(ex.toString());}
	}
	
	
	public static User getUserByUID(long uid, ArrayList<User> users) {
		
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
	
	public String getCurrent_location() {
		return current_location;
	}


	public void setCurrent_location(String current_location) {
		this.current_location = current_location;
	}


	public String getLocation() {
		return current_location;
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

	public String getAccess_token() {
		return access_token;
	}

	public void setAccess_token(String access_token) {
		this.access_token = access_token;
	}
}
