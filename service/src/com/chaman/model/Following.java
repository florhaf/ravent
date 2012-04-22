package com.chaman.model;

import java.util.ArrayList;
import java.io.Serializable;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.chaman.model.User;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.googlecode.objectify.annotation.Entity;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

@Entity
public class Following extends Model implements Serializable  {

	/**
	 * 
	 */
	private static final long serialVersionUID = 506213411449400185L;
	@Id
	String id; // concatenation of userID and friendID
	Long userID;
	Long friendID;
	
	static {
		try {
			ObjectifyService.register(Following.class);
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}
	
	public Following() {
		
	}
	
	public Following(Long userID, Long friendID) {
		
		this.id = String.valueOf(userID)+String.valueOf(friendID); // key for following
		this.userID		= userID;
		this.friendID	= friendID;
	}
	
	public static ArrayList<Model> Get(String accessToken, String userID, Boolean isFollowing) {
		
		ArrayList<Model> users = new ArrayList<Model>();
		
		Dao dao = new Dao();
		
		Following fcache = null;
		User ucache = null;
		
	    MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();

		Query<Following> q = dao.ofy().query(Following.class);
		q.filter(isFollowing ? "userID" : "friendID", Long.parseLong(userID));
		
        for (Following f : q) {
        	
        	User u = new User();
        	u.uid = isFollowing ? f.friendID : f.userID;

    	    fcache = (Following) syncCache.get(f.id); // read from following cache
    	    if (fcache == null) {
    	    	
        		Query<Following> qfollowings = dao.ofy().query(Following.class);
    	    	qfollowings.filter("userID", u.uid);
    	    	u.nb_of_following = qfollowings.count();
    	    	
    			Query<Following> qfollowers = dao.ofy().query(Following.class);    	
    	    	qfollowers.filter("friendID", u.uid);
    	    	u.nb_of_followers = qfollowers.count();   	
    	    	
    	    	syncCache.put(f.id, f); // populate following cache
    	    } else {
    	    	
    	    	ucache = (User) syncCache.get(u.uid); //read from user cache to get the nb following/ers values
    	    	if (ucache != null) {
    	    		
    	    		u.nb_of_following = ucache.nb_of_following;
    	    		u.nb_of_followers = ucache.nb_of_followers;
    	    	} else {
    	    		
    	    		//this "else" case should not happen but just in case
    	    		Query<Following> qfollowings = dao.ofy().query(Following.class);
        	    	qfollowings.filter("userID", u.uid);
        	    	u.nb_of_following = qfollowings.count();
        	    	
        	    	Query<Following> qfollowers = dao.ofy().query(Following.class);   
        	    	qfollowers.filter("friendID", u.uid);
        	    	u.nb_of_followers = qfollowers.count();
        	    	
        	    	syncCache.put(f.id, f); // populate following cache
    	    	}
    	    }
        	users.add(u);
        }
               
        return User.GetMultiples(accessToken, users);
	}
	
	public static void Put(String userID, String friendID) {
		
		Following fcache;
		
		Following f = new Following(Long.parseLong(userID), Long.parseLong(friendID));
	
	    MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	    fcache = (Following) syncCache.get(f.id); // read from cache
	    if (fcache == null) {
	    	
			Dao dao = new Dao();
			
			Query<Following> q = dao.ofy().query(Following.class);
	        q.filter("id", f.id);
			
	        if (q.count() == 0) {
	        	
	    		dao.ofy().put(f);
	        }

	      syncCache.put(f.id, f); // populate cache
	      syncCache.delete(Long.parseLong(userID)); // to refresh the data at the next call of following()
	      syncCache.delete(Long.parseLong(friendID)); // to refresh the data at the next call of following()
	    }
	}
	
	public static void Delete(String userID, String friendID) {
		
		Dao dao = new Dao();
		
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		
		Following f = new Following(Long.parseLong(userID), Long.parseLong(friendID));
        	
        dao.ofy().delete(f);
        syncCache.delete(userID + friendID); //delete Following from cache
        syncCache.delete(Long.parseLong(userID)); // to refresh the data at the next call of following()
        syncCache.delete(Long.parseLong(friendID));// to refresh the data at the next call of following()
	}
	
	public void setUserID(long userID) {
		
		this.userID = userID;
	}
	
	public void setFriendID(long friendID) {
		
		this.friendID = friendID;
	}
	
	public long getUserID() {
		
		return this.userID;
	}
	
	public long getFriendID() {
		
		return this.friendID;
	}
}
