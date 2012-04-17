package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class Attending extends Model {

	@Facebook
	long uid;
	@Facebook
	String first_name;
	@Facebook
	String last_name;
	@Facebook
	String pic;
	@Facebook
	String rsvp_status;
	
	String picture;
	
	public Attending() {
		super();
	}
	
	public static ArrayList<Model> Get(String accessToken, String userID, String eid) throws FacebookException {
		
		ArrayList<Model> result 	= new ArrayList<Model>();
		
		FacebookClient client 		= new DefaultFacebookClient(accessToken);
		
		String properties 			= "uid, first_name, last_name, pic";
		String query 				= "SELECT " + properties + " FROM user WHERE uid IN (SELECT uid FROM event_member WHERE eid = " + eid + 
																		   " AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me()))";
		List<Attending> Attendings 	= client.executeQuery(query, Attending.class);
		
		String queryRsvp;
		List<Attending> rsvpStatuses;
		
		for (Attending a : Attendings) {
			
			a.picture = a.pic;
			
			// REALLY HUGLY HACK...
			queryRsvp = "SELECT rsvp_status FROM event_member WHERE eid = " + eid + " AND uid = " + a.uid;
			rsvpStatuses 	= client.executeQuery(queryRsvp, Attending.class);
			
			a.rsvp_status = rsvpStatuses.get(0).getRsvp_status();
			
			if (a.rsvp_status.equals("unsure") || a.rsvp_status.equals("not_replied")) {
				
				a.rsvp_status = "maybe attending";
			} else if (a.rsvp_status.equals("declined")) {
				
				a.rsvp_status = "not attending";
			}
			//...
			
			result.add(a);
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
	
	public String getRsvp_status() {
		
		return this.rsvp_status;
	}
}
