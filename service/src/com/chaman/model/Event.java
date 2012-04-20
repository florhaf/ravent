package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.LocationCapableRepositorySearch;
import com.beoui.geocell.model.Point;
import com.chaman.dao.Dao;
import com.chaman.util.Geo;
import com.chaman.util.JSON;
import com.googlecode.objectify.Query;
import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

import com.chaman.model.Attending;

/*
 * Event object from FB + formatting for our app
 */
public class Event extends Model {

	@Facebook
	Long eid;
	@Facebook
	String name;
	@Facebook
	String pic;
	@Facebook
	String venue;
	@Facebook
	String location;
	@Facebook
	String start_time;
	@Facebook
	String end_time;
	@Facebook
	String description;
	@Facebook
	String host;
	@Facebook
	String creator; /*promoter ID*/
	
	int score;
	long nb_invited;
	String group;
	String latitude;
	String longitude;
	String time_start;
	String time_end;
	String date_start;
	String date_end;
	String picture;
	String invited_by;
	String distance;
	String groupTitle;
	String type; // need to query google app to get the type of the place (club, bar etc) / or using the location in FB Page
	
	User user;
	
	DateTime dtStart;
	DateTime dtEnd;
	
//	static {
//		try {
//			ObjectifyService.register(Event.class);
//		} catch (Exception ex) {
//			System.out.println(ex.getMessage());
//		}
//	}
	
	public Event() {
		
		super();
	}
	
	/*
	 * - Get list of events from facebook for a userID
	 * - store in our DB events w/ latitude and longitude
	 * - exclude past events
	 */
	public static ArrayList<Model> Get(String accessToken, String userID, String userLatitude, String userLongitude, String timeZone) throws FacebookException {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "eid, name, pic, start_time, end_time, venue, location, host, creator";
		String query 			= "SELECT " + properties + " FROM event WHERE eid IN (SELECT eid FROM event_member WHERE uid = " + userID + ") ORDER BY start_time"; /*need to check privacy CLOSED AND SECRET */
		List<Event> fbevents 	= client.executeQuery(query, Event.class);
		
		Dao dao = new Dao();
		
		int timeZoneInMinutes = Integer.parseInt(timeZone);
		
		for (Event e : fbevents) {
						
			e.Format(timeZoneInMinutes);
			
			if (!e.IsPast()) {
				
				e.latitude 	= JSON.GetValueFor("latitude", e.venue);
				e.longitude = JSON.GetValueFor("longitude", e.venue);
				
				if (e.latitude != null && e.latitude != "" && e.longitude != null && e.longitude != "") {
				
					Query<EventLocationCapable> q = dao.ofy().query(EventLocationCapable.class);
			        q.filter("eid", e.eid);
					
			        if (q.count() == 0) {
			        	
			        	e.Score();
			        	e.getNb_invited(accessToken);
			        	EventLocationCapable elc = new EventLocationCapable(e);
			        	dao.ofy().put(elc);
			        } else {
			        	
			        	e.Score();
			        	// update score in DB
			        	// update nb invited in DB
			        	
			        }
			        
			        float distance = Geo.Fence(userLatitude, userLongitude, e.latitude, e.longitude);
					
					e.distance = String.format("%.2f", distance);
				} else {
					
					e.distance = "N/A";
				}
				
				result.add(e);
			}
		}
		
		return result;
	}
	
	/*
	 * - Get list of event for any user in search area
	 * - exclude past event
	 */
	public static ArrayList<Model> Get(String accessToken, String userLatitude, String userLongitude, String timeZone, int searchTimeFrame, int searchRadius, int searchLimit) throws FacebookException {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		Dao dao = new Dao();
		
		LocationCapableRepositorySearch<EventLocationCapable> ofySearch = new OfyEntityLocationCapableRepositorySearchImpl(dao.ofy(), timeZone, searchTimeFrame);
		List<EventLocationCapable> l = GeocellManager.proximityFetch(new Point(Double.parseDouble(userLatitude), Double.parseDouble(userLongitude)), searchLimit, searchRadius * 1000, ofySearch);
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "eid, name, pic, start_time, end_time, venue, location, host";
	
		int timeZoneInMinutes = Integer.parseInt(timeZone);
		
        for (EventLocationCapable e : l) {
        	
    		String query 			= "SELECT " + properties + " FROM event WHERE eid = " + e.getEid();
    		List<Event> fbevents 	= client.executeQuery(query, Event.class);
        	
    		if (fbevents != null && fbevents.size() > 0) {
    			
    			Event event = fbevents.get(0);
    			event.Format(timeZoneInMinutes);    		
    			
    			if (!event.IsPast()) {
    				
    				event.score = e.getScore();
    				event.nb_invited = e.getNb_invited();
    				event.latitude 	= Double.toString(e.getLatitude());
    				event.longitude = Double.toString(e.getLongitude());
    				
    				float distance = Geo.Fence(userLatitude, userLongitude, event.latitude, event.longitude);
            		event.distance = String.format("%.2f", distance);
            		
                	result.add(event);
    			}
    		}
        }
		
		return result;
	}
	
	private void Format(int timeZoneInMinutes) {
		
		// format misc.
		this.picture	= this.pic;
		this.invited_by = this.host;
		
		long timeStampStart = Long.parseLong(this.start_time) * 1000;
		long timeStampEnd = Long.parseLong(this.end_time) * 1000;
		
		// facebook events timestamp are in PST
		DateTimeZone PST = DateTimeZone.forID("America/Los_Angeles");
		
		this.dtStart = new DateTime(timeStampStart, PST);
		this.dtEnd = new DateTime(timeStampEnd, PST);
		
		// so need to add time zone offset
		this.dtStart.plusMinutes(timeZoneInMinutes);
		this.dtEnd.plusMinutes(timeZoneInMinutes);
		
		this.time_start = dtStart.toString("KK:mm a");
		this.time_end = dtEnd.toString("KK:mm a");
		
		this.date_start = dtStart.toString("MMM d, Y");
		this.date_end = dtEnd.toString("MMM d, Y");
		
		if (dtStart.getDayOfYear() <= DateTime.now().getDayOfYear() && dtEnd.dayOfYear().get() >= DateTime.now().getDayOfYear()) {
			
			this.group = "a";
			this.groupTitle = "Today";
		} else {
			
			if (dtStart.getDayOfYear() <= DateTime.now().plusDays(1).getDayOfYear()) {
				
				this.group = "b";
				this.groupTitle = "Tomorrow";
			} else {
				
				if (dtStart.getDayOfYear() <= DateTime.now().plusWeeks(1).getDayOfYear()) {
					
					this.group = "c";
					this.groupTitle = "This week";
				} else {
					
					if (dtStart.getDayOfYear() <= DateTime.now().plusMonths(1).getDayOfYear()) {
						
						this.group = "d";
						this.groupTitle = "This month";
					} else {
						
						this.group = "e";
						this.groupTitle = "Later";
					}
				}
			}
		}
	}
	
	
	/* 
	 * - Get the list of users invited to the event (pic name rsvp status)
	 * - Fill the number of user invited (this.nb_invited)
	 */
	public ArrayList<Model> InvitedList(String accessToken) throws FacebookException {
		
		ArrayList<Model> result 	= new ArrayList<Model>();
		
		FacebookClient client 		= new DefaultFacebookClient(accessToken);
		
		String properties 			= "uid, first_name, last_name, pic, rsvp_status";
		String query 				= "SELECT " + properties + " FROM user WHERE uid IN (SELECT uid FROM event_member WHERE eid = " + this.getEid();
		List<Attending> Attendings 	= client.executeQuery(query, Attending.class);
		
		this.nb_invited = Attendings.size();
		
		for (Attending a : Attendings) {
			a.picture = a.pic;
			
			if (a.rsvp_status.equals("unsure") || a.rsvp_status.equals("not_replied")) {
				
				a.rsvp_status = "maybe attending";
			} else if (a.rsvp_status.equals("declined")) {
				
				a.rsvp_status = "not attending";
			}
			
			result.add(a);
		}
 	
		return result;
	}
	
	/* 
	 * - Get the number of users invited
	 */
	public long getNb_invited(String accessToken) throws FacebookException {
		
		FacebookClient client 		= new DefaultFacebookClient(accessToken);
		
		String query 				= "SELECT uid FROM event_member WHERE eid = " + this.getEid();
		List<Attending> Attendings 	= client.executeQuery(query, Attending.class);
		
		this.nb_invited = Attendings.size();
 	
		return this.nb_invited;
	}
	
	private void Score() {
	
		this.score = 1 + (int) (Math.random() * ((5 - 1) + 1));
	}
	
	private Boolean IsPast() {
				
		return dtEnd.isBeforeNow();
	}
	
	public long getEid() {
		
		return this.eid;
	}
	
	public String getName() {
		
		return this.name;
	}
	
	public String getPicture() {
		
		return this.picture;
	}
	
	public String getGroup() {
		
		return this.group;
	}
	
	public String getDescription() {
		
		return this.description;
	}
	
	public String getVenue() {
		
		return this.venue;
	}
	
	public String getLocation() {
		
		return this.location;
	}
	
	public int getScore() {
		
		return this.score;
	}
	
	public String getDistance() {
		
		return this.distance;
	}
	
	public String getTime_start() {
		
		return this.time_start;
	}
	
	public String getTime_end() {
		
		return this.time_end;
	}
	
	public String getDate_start() {
		
		return this.date_start;
	}
	
	public String getDate_end() {
		
		return this.date_end;
	}
	
	public String getInvited_by() {
		
		return this.invited_by;
	}
	
	public String getLatitude() {
		
		return this.latitude;
	}
	
	public long getNb_invited() {
		
		return this.nb_invited;
	}
	
	public String getLongitude() {
		
		return this.longitude;
	}
	
	public String getGroupTitle() {
		return groupTitle;
	}

	public void setGroupTitle(String groupTitle) {
		this.groupTitle = groupTitle;
	}
}
