package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;

/*
 * event object we store in our DB
 */
@Entity
public class EventMarketingProgram extends Model {

	@Id
	long eid;
	@Unindexed
	String features;
	@Unindexed
	long offer_id;
	@Unindexed
	String title;
	@Unindexed
	String terms;
	@Unindexed
	String ticket_link;
    
	public EventMarketingProgram() {
		
		super();
	}
	
	public EventMarketingProgram(long eid, String features, String title, String terms, String ticket_link) {
	
		this.eid = eid;
		this.features = features;
		// TODO this.offer_id = 0; //to get from FB later on.
		this.title = title;
		this.terms = terms;
		this.ticket_link = ticket_link;
	}
	
    public static ArrayList<Model> PutEventMarketingProgram(long eid, String features, String title, String terms, String ticket_link) {
    
    	EventMarketingProgram emp = new EventMarketingProgram(eid, features, title,terms, ticket_link);
    	
    	Dao dao = new Dao();
    	 	  	
    	dao.ofy().put(emp);
    	
    	return null;
    }

    public static ArrayList<Model> GetEventMarketingProgram(long eid) {
    
    	List<Model> result = new ArrayList<Model>();
    	
    	Dao dao = new Dao();
    	
    	EventMarketingProgram emp = dao.ofy().find(EventMarketingProgram.class, eid);
    	
    	result.add(emp);
    	
    	return (ArrayList<Model>)result;
    }
    	
	public long getEid() {
		return eid;
	}

	public void setEid(long eid) {
		this.eid = eid;
	}

	public String getFeatured() {
		return features;
	}

	public void setFeatured(String featured) {
		this.features = featured;
	}

	public long getOffer_id() {
		return offer_id;
	}

	public void setOffer_id(long offer_id) {
		this.offer_id = offer_id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getTerms() {
		return terms;
	}

	public void setTerms(String terms) {
		this.terms = terms;
	}

	public String getTicket_link() {
		return ticket_link;
	}

	public void setTicket_link(String ticket_link) {
		this.ticket_link = ticket_link;
	}
}
