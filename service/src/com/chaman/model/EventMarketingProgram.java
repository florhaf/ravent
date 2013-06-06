package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;

import com.beoui.geocell.GeocellUtils;
import com.beoui.geocell.model.Point;
import com.chaman.dao.Dao;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.Parameter;
import com.restfb.types.FacebookType;

/*
 * event object we store in our DB
 */
@Entity
public class EventMarketingProgram extends Model {

	static {
		try {

			ObjectifyService.register(EventMarketingProgram.class);
		} catch (Exception ex) {
			
			//System.out.println(ex.toString());
		}
	}
	
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
	long timeStampStart;
	long timeStampEnd;
	List<String> geocells;
	
	public EventMarketingProgram() {
		
		super();
	}
	
	public EventMarketingProgram(long eid, String features, String title, String terms, String ticket_link, String starttime, String endtime, String lat, String lon) {
	
		this.eid = eid;
		this.features = features;
		// TODO this.offer_id = 0; //to get from FB later on.
		this.title = title;
		this.terms = terms;
		this.ticket_link = ticket_link;
		
		this.timeStampStart = Long.parseLong(starttime);
		this.timeStampEnd = Long.parseLong(endtime);
		
		this.geocells = new ArrayList<String>();
    	this.geocells.add(GeocellUtils.compute(new Point(Double.parseDouble(lat), Double.parseDouble(lon)), 6));
	}
	
    public static ArrayList<Model> PutEventMarketingProgram(String userID, String accessToken, long eid, String features, String title, String terms, String ticket_link, String timeZone) {
    
    	String message = (title != null && !title.isEmpty() ? "| Drop Gems to unlock the goodies" + ((features != null && !features.isEmpty()) && features.contains("RAF") ? " and raffles: " : ": ") + title : "") + (ticket_link != null && !ticket_link.isEmpty() ? " | Tickets available on Gemster |" : "|");
    	
    	//get event from DS (before)
    	Event e = Event.getSingle(accessToken, String.valueOf(eid), timeZone, null, null, null, null);
    	
    	EventMarketingProgram emp = new EventMarketingProgram(eid, features, title, terms, ((ticket_link != null && !ticket_link.isEmpty()) && !ticket_link.contains("http") ? "http://" + ticket_link : ticket_link), e.start_time, e.end_time, e.latitude, e.longitude);	
    	
    	//delete event from cache (if any) to force update at next call of events
    	MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
    	syncCache.delete(eid);
    	
    	Dao dao = new Dao(); 	  	
    	dao.ofy().put(emp);
    	
    	Promoter.Put(userID, e != null ? e.creator : null, features, title, ticket_link);
    	   	
		try {
   
			FacebookClient client 	= new DefaultFacebookClient(accessToken);
			client.publish(eid + "/feed", FacebookType.class, Parameter.with("message", message), Parameter.with("link", "https://apps.facebook.com/gemsterapp/?eid=" + eid),
    				Parameter.with("name", "See more"), Parameter.with("picture", "http://gemsterapp.com/img/app_icon.png"));
		
			client.publish(e.creator + "/gemsterapp:drop_a_gem_on", FacebookType.class, Parameter.with("event", "https://apps.facebook.com/gemsterapp/?eid=" + eid));
		} catch (Exception ex) {}
    	
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

	public String getFeatures() {
		return features;
	}

	public void setFeatures(String features) {
		this.features = features;
	}

	public long getTimeStampStart() {
		return timeStampStart;
	}

	public void setTimeStampStart(long timeStampStart) {
		this.timeStampStart = timeStampStart;
	}

	public long getTimeStampEnd() {
		return timeStampEnd;
	}

	public void setTimeStampEnd(long timeStampEnd) {
		this.timeStampEnd = timeStampEnd;
	}

	public List<String> getGeocells() {
		return geocells;
	}

	public void setGeocells(List<String> geocells) {
		this.geocells = geocells;
	}
}
