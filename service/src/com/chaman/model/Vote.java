package com.chaman.model;

import java.io.Serializable;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;
import com.google.appengine.api.memcache.AsyncMemcacheService;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.types.FacebookType;

@Entity
public class Vote extends Model implements Serializable  {

	static {
		try {

			ObjectifyService.register(Vote.class);
		} catch (Exception ex) {
			
			//System.out.println(ex.toString());
		}
	}
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1850811476103169817L;
	@Id
	String eid; //String => can be cached and will be identified differently from the Long in ELC
	@Unindexed
	Long nb_vote;
	
	public Vote () {
		
		super();
	}
	
	public Vote (String eid, Long nb_vote) {
		
		this.eid = eid;
		this.nb_vote = nb_vote;
	}
	
	public Vote(String accessToken, String userid, String eventid, String svote, boolean visibility, String message) {
		
		Dao dao = new Dao();
		
		this.eid = eventid;
		
		AsyncMemcacheService asyncCache = MemcacheServiceFactory.getAsyncMemcacheService();
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		
		Vote v_cache; 
	
		v_cache = (Vote) syncCache.get(eventid); // read from vote cache
	    if (v_cache == null) {
	    	
	    	//get from DS
	    	Vote dsvote = dao.getVote(this.eid);
	    	this.nb_vote = dsvote.nb_vote + 1;
	    } else {
	    	
	    	this.nb_vote = v_cache.nb_vote + 1;
	    }

	    if (!visibility || (visibility && this.nb_vote == 1)) {
	    
	    	dao.ofy().put(this);
	    	Promoter.AddVote(eventid, accessToken);
	    	asyncCache.put(this.eid, this, null); // Add vote to cache
	    	asyncCache.delete(Long.parseLong(this.eid)); //Delete event from cache to refresh the event score when somebody has voted
	    	
    		FacebookClient client 	= new DefaultFacebookClient(accessToken);
    		
    		try {
        		client.publish(eventid + "/feed", FacebookType.class, Parameter.with("message", message), Parameter.with("link", "https://apps.facebook.com/gemsterapp/#event/" + eventid + "?eid=" + eventid),
        				Parameter.with("name", "Click to see more about this event"), Parameter.with("picture", "http://gemsterapp.com/img/app_icon.png"));
        	} catch (Exception ex) {}
    		
    		if (!visibility) {
    			new VoteDetails(eventid, userid);
    			client.publish(userid + "/gemsterapp:drop_a_gem_on", FacebookType.class, Parameter.with("event", "https://apps.facebook.com/gemsterapp/#event/" + eventid + "?eid=" + eventid));
    		}
    	}
	}
	
	public String getEid() {
		
		return this.eid;
	}
	
	public void setEid(String eventid) {
		
		this.eid = eventid;
	}
	
	public Long getNb_vote() {
		
		return this.nb_vote;
	}
	
	public void setNb_vote(Long nbvote) {
		
		this.nb_vote = nbvote;
	}
	
	
	
}
	
