package com.chaman.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ArrayBlockingQueue;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;

import com.chaman.dao.Dao;
import com.chaman.util.EventTools;
import com.chaman.util.Geo;
import com.chaman.util.JSON;
import com.chaman.util.MyThreadManager;
import com.google.appengine.api.memcache.AsyncMemcacheService;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceException;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class EventUser extends Model implements Runnable {

	MyThreadManager<Event> tm;

	int timeZoneInMinutes;
	Map<Long, Object> map_cache;
	String locale;
	String userLatitude;
	String userLongitude;
	FacebookClient client;
	DateTime now;
	
	/*
	 * - Get list of events from facebook for a userID
	 * - store in our DB events w/ latitude and longitude
	 * - exclude past events
	 */
	public static ArrayList<Model> Get(String accessToken, String userID, String userLatitude, String userLongitude, String timeZone, String locale) throws FacebookException , MemcacheServiceException {
	
		List<Model> result = new ArrayList<Model>();
		
		EventUser eu = new EventUser();
		
		eu.timeZoneInMinutes = Integer.parseInt(timeZone);
		
		//Prepare a timestamp to filter the facebook DB on the upcoming events
		DateTimeZone TZ = DateTimeZone.forOffsetMillis(eu.timeZoneInMinutes*60*1000);
		DateTime now = DateTime.now(TZ);	
		long actual_time = now.getMillis() / 1000;
		String str_actual_time = String.valueOf(actual_time);
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "eid, name, pic_big, start_time, end_time, venue, location, privacy, update_time, all_members_count, timezone, creator";

		eu.locale = locale;
		eu.userLatitude = userLatitude;
		eu.userLongitude = userLongitude;
		eu.client = client;
		eu.now = now;
		
		String query 			= "SELECT " + properties + " FROM event WHERE eid IN (SELECT eid FROM event_member WHERE uid = " + userID + ") AND end_time > " + str_actual_time + " ORDER BY start_time";
		List<Event> fbevents 	= client.executeQuery(query, Event.class);
		
		if (fbevents != null && !fbevents.isEmpty()) {
			
			eu.tm = new MyThreadManager<Event>(eu);
			
			MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
			
			List<Long> eventkeys = EventTools.getEventkeys(fbevents);
			
			eu.map_cache = syncCache.getAll(eventkeys);
			
			Queue<Event> q = new ArrayBlockingQueue<Event>(fbevents.size());
			q.addAll(fbevents);
			
			result = eu.tm.Process(q, 30000);
		}

		return (ArrayList<Model>) result;
	}


	@Override
	public void run() {
		
		try {
			
			AsyncMemcacheService asyncCache = MemcacheServiceFactory.getAsyncMemcacheService();
			
			Dao dao = new Dao();
			
			Event e_cache; 
			
			Event e = this.tm.getIdForThread(Thread.currentThread());

			e_cache = (Event) map_cache.get(e.getEid()); // read from Event cache
    	    if (e_cache == null || !e_cache.update_time.equals(e.update_time)) {
    	    	
    	    	e.venue_id = JSON.GetValueFor("id", e.venue);
    	    	Venue v_graph = Venue.getVenue(client, e.venue_id, e);
    	    	e.venue_category = v_graph.category;
    	    	
    	    	e.Filter_category();
    	    	
    	    	e.Score(v_graph);
    	    	
    	    	e.latitude 	= JSON.GetValueFor("latitude", e.venue);
    	    	e.longitude = JSON.GetValueFor("longitude", e.venue);
    	    	
    	    	if ((e.latitude == null || e.longitude == null) && v_graph != null) {
				
    	    		// take value from venue if event location is null
    	    		e.latitude = JSON.GetValueFor("latitude", v_graph.location);
    	    		e.longitude = JSON.GetValueFor("longitude", v_graph.location);
    	    	}	

    	    	if (e.latitude != null && e.longitude != null && (e.privacy != null && e.privacy.equals("OPEN"))) {
				
    	    		EventLocationCapable elc = dao.ofy().find(EventLocationCapable.class, e.eid);
    	    		
    	    		if (elc == null) {
    	    			dao.ofy().put(new EventLocationCapable(e));
    	    		} else if (elc.getTimeStampStart() != Long.parseLong(e.start_time) || elc.getTimeStampEnd() != Long.parseLong(e.end_time)){
    	    			dao.ofy().put(elc);
    	    		}
    	    	}    	    	
    	    } else {
    	    	
    	    	e = e_cache;
    	    }
  	    
	    	e.Format(timeZoneInMinutes, now, 0, locale, null);
	    	
	    	if (e.latitude != null && e.longitude != null) {

    	    	float distance = Geo.Fence(userLatitude, userLongitude, e.latitude, e.longitude);
        	    e.distance = String.format("%.2f", distance);
	    	    asyncCache.put(e.eid, e, null); // Add Event to cache
    	    } else {
				
	    		e.distance = "N/A";
	    	}
	    
	    	this.tm.AddToResultList(e);
		} catch (Exception ex) {
			
			log.severe(ex.toString());
		} finally {
		
			tm.threadIsDone(Thread.currentThread());
		}
		
	}
	
	public static  ArrayList<Model> Get(String accessToken, String userID, String userLatitude, String userLongitude, String timeZone, String locale, boolean promoter) {
			
		ArrayList<Model> res = new ArrayList<Model>();
		ArrayList<Model> result = new ArrayList<Model>();
		
		//get user ID events
		res = Get(accessToken, userID, userLatitude, userLongitude, timeZone, locale);
		
		
		//get the pages id administered by user
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String query 			= "SELECT page_id from page_admin WHERE uid =" + userID;
		List<Profile> pages 	= client.executeQuery(query, Profile.class);

		if (pages != null && pages.size() > 0) {
			
			for (Profile p : pages) {
				
				res.addAll(Get(accessToken, p.page_id, userLatitude, userLongitude, timeZone, locale));
			}
		}
		
		if (res != null && res.size() > 0) {
			
			for (Model e : res) {
				
				Event event = (Event) e;
				
				if (event.creator != null && iscreator(userID, pages, event.creator)) {
					
					result.add(event);
				}
				
			}
		}
		
		return result;
	}


	private static boolean iscreator(String userID, List<Profile> pages, String creator) {
		
		if (creator.equals(userID)) {
			
			return true;
		}
		
		if (pages != null && pages.size() > 0) {
			
			for (Profile p : pages) {
				
				if (creator.equals(p.page_id)) {
					return true;
				}
			}
		}
		
		return false;
	}
}
