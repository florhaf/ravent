package com.chaman.model;

import java.util.List;
import java.util.Queue;
import java.util.concurrent.ArrayBlockingQueue;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;

import com.chaman.dao.Dao;
import com.chaman.util.JSON;
import com.chaman.util.MyThreadManager;
import com.google.appengine.api.memcache.AsyncMemcacheService;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceException;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.googlecode.objectify.Query;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class EventFetchCron extends Model implements Runnable {

	MyThreadManager<User> tm;
	
	public static void GetCron() throws FacebookException, MemcacheServiceException {
		
		Dao dao = new Dao();
		
		int users_count;
		
		EventFetchCron efc = new EventFetchCron();
	
		//get users and Access tokens from DS		
		Query<User> quser = dao.ofy().query(User.class);
		
		efc.tm = new MyThreadManager<User>(efc);
		
		users_count = quser.count();
		
		Queue<User> q = new ArrayBlockingQueue<User>(users_count);
		q.addAll(quser.list());
		
		efc.tm.Process(q, 30000);
		
	}	

	@Override
	public void run() {

		try {
			
			User u = this.tm.getIdForThread(Thread.currentThread());
			
			Dao dao = new Dao();

			MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
			AsyncMemcacheService asyncCache = MemcacheServiceFactory.getAsyncMemcacheService();
			
			try {

				//Prepare a timestamp to filter the facebook DB on the upcoming events
				DateTimeZone PST = DateTimeZone.forID("America/Los_Angeles"); 	
				DateTime now_plus_1month =  new DateTime(PST).plusDays(45);
				String snow_plus_1month = String.valueOf(now_plus_1month.getMillis() / 1000L);
				DateTime now_minus1day =  new DateTime(PST).plusDays(-1);
				String snow_minus1day = String.valueOf(now_minus1day.getMillis() / 1000L);
				
				//Get friend list 
				List<Friend> uidList = Friend.GetCron(u.getAccess_token(), Long.toString(u.getUid()), syncCache);

				//Loop to get all events	
				for (Friend l : uidList) {

					try {

						FacebookClient client 	= new DefaultFacebookClient(u.getAccess_token());
						String properties 		= "eid, name, pic_big, start_time, end_time, venue, location, privacy, update_time, all_members_count, timezone, creator";
						String query 			= "SELECT " + properties + " FROM event WHERE eid IN (SELECT eid FROM event_member WHERE uid = " + l.getUid() + ") AND start_time < " + snow_plus_1month + " AND start_time > " + snow_minus1day + " AND privacy = 'OPEN'";
						List<Event> fbevents 	= client.executeQuery(query, Event.class);

						Event e_cache; 

						for (Event e : fbevents) {

							try {
								
								e_cache = (Event) syncCache.get(e.eid); // read from Event cache
								if (e_cache == null || !e_cache.update_time.equals(e.update_time)) {

									e.venue_id = JSON.GetValueFor("id", e.venue);    	
									Venue v_graph =  Venue.getVenue(client, e.venue_id, e);
									e.venue_category = v_graph.category;

									if (e.venue_category == null || !e.venue_category.equals("city")) {

										e.Score(v_graph);

										e.Filter_category();

										e.latitude 	= JSON.GetValueFor("latitude", e.venue);
										e.longitude = JSON.GetValueFor("longitude", e.venue);

										if (v_graph != null && (e.latitude == null || e.longitude == null)) {

											// take value from venue if event location is null
											e.latitude = JSON.GetValueFor("latitude", v_graph.location);
											e.longitude = JSON.GetValueFor("longitude", v_graph.location);
										}	

										if (e.latitude != null && e.longitude != null) {

											EventLocationCapable elc = dao.ofy().find(EventLocationCapable.class, e.eid);

											if (elc == null) {
												dao.ofy().put(new EventLocationCapable(e));
											} else if (elc.getTimeStampStart() != Long.parseLong(e.start_time) || elc.getTimeStampEnd() != Long.parseLong(e.end_time)){
												dao.ofy().put(new EventLocationCapable(e));
											}
											asyncCache.put(e.eid, e, null); // Add Event to cache
										}
									}
								} else {

									asyncCache.put(e_cache.eid, e_cache, null); // Add cache Event to cache -> more recent date
								}
							} catch (Exception ex ) {/*log.severe("Event loop " + ex.toString());*/}
						}
					} catch (Exception ex ) {log.severe("Get Events for friend of " + u.uid + "-" + l.uid + " " + ex.toString()); wait(600001); }
				}		
			} catch (Exception ex) {/*log.severe("Get friends list " + ex.toString());*/}

		} catch (Exception ex){

			//log.severe("run " + ex.toString());
		}finally {

			tm.threadIsDone(Thread.currentThread());
		}

	}	
}
