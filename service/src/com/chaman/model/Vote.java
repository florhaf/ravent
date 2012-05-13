package com.chaman.model;

import java.io.Serializable;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.annotation.Entity;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

@Entity
public class Vote extends Model implements Serializable  {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1850811476103169817L;
	@Id
	String eid; //String => can be cached and will be identified differently from the Long in ELC
	Long nb_vote;
	Double vote_avg;
	
	static {
		try {
			ObjectifyService.register(Vote.class);
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}
	
	public Vote () {
		
		super();
	}
	
	public Vote(String accessToken, String userid, String eventid, String svote) {
		
		Dao dao = new Dao();
		Double lvote = Double.valueOf(svote);
		this.eid = eventid;
		
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
		Vote v_cache; 
		
		v_cache = (Vote) syncCache.get(eventid); // read from vote cache
	    if (v_cache == null) {
	    	
	    	//get from DS
	    	Vote dsvote = null;
	    	dsvote = dao.ofy().find(Vote.class, this.eid);
	    	
	    	if (dsvote != null) {
	    		
	    		this.nb_vote = dsvote.nb_vote + 1;
	    		this.vote_avg = ((dsvote.vote_avg * dsvote.nb_vote) + lvote) / this.nb_vote;
	    	} else {
	    	
	    		this.nb_vote = 1L;
	    		this.vote_avg = lvote;
	    	}
	    } else {
	    	
	    	this.nb_vote = v_cache.nb_vote + 1;
	    	this.vote_avg = ((v_cache.vote_avg * v_cache.nb_vote) + lvote) / this.nb_vote;
	    }
		
		dao.ofy().put(this);
    	syncCache.put(this.eid, this); // Add vote to cache
    	
    	//TODO: Facebook post? like?
	}
	
	public static void NewVote(String userid, String eventid, String svote) {
		
		//Vote newvote = new Vote(userid, eventid, svote);	
	}
	
	public String getEid() {
		
		return this.eid;
	}
	
	public void setEid(String eventid) {
		
		this.eid = eventid;
	}
	
	public Double getVote_avg() {
		
		return this.vote_avg;
	}
	
	public void setVote_avg(Double voteavg) {
		
		this.vote_avg = voteavg;
	}
	
	public Long getNb_vote() {
		
		return this.nb_vote;
	}
	
	public void setNb_vote(Long nbvote) {
		
		this.nb_vote = nbvote;
	}
	
	
	
}
	
