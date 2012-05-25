package com.chaman.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;
import com.restfb.types.FacebookType;

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
	
	Long eid;
	String picture;
	
	public Attending() {
		super();
	}
	
	public static ArrayList<Model> GetInvitedFriendsList(String accessToken, String userID, String eid) throws FacebookException {
		
		ArrayList<Model> result 	= new ArrayList<Model>();
		
		FacebookClient client 		= new DefaultFacebookClient(accessToken);
		
		Long eid_long = Long.parseLong(eid);

		//initiate multiquery for FB (one call for multiple queries = optimization)
		Map<String, String> queries = new HashMap<String, String>();
		queries.put("friends", "SELECT uid2 FROM friend WHERE uid1 = me()");
		queries.put("friends_invited_rsvp", "SELECT uid, rsvp_status FROM event_member WHERE eid = " + eid + " AND uid in (select uid2 from #friends)");
		queries.put("friends_invited_info", "SELECT uid, first_name, last_name, pic FROM user WHERE uid in (select uid from #friends_invited_rsvp)");

		MultiqueryResults multiqueryResult = client.executeMultiquery(queries, MultiqueryResults.class);
		
		for (int i=0; i<multiqueryResult.friends_invited_info.size(); i++) {
		
			Attending a = multiqueryResult.friends_invited_info.get(i);
			
			a.picture = a.pic;
			a.eid = eid_long;
			
			a.rsvp_status = multiqueryResult.friends_invited_rsvp.get(i).rsvp_status;
			
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
	 * - Get the list of users ATTENDING (not all the invited people) to the event (pic name rsvp status)
	 * - Fill the number of user invited (this.nb_invited)
	 */
	public static ArrayList<Model> GetAttendingAllList(String accessToken, String eid) throws FacebookException {
		
		ArrayList<Model> result 	= new ArrayList<Model>();
		
		FacebookClient client 		= new DefaultFacebookClient(accessToken);
		
		Long eid_long = Long.parseLong(eid);

		//initiate multiquery for FB (one call for multiple queries = optimization)
		Map<String, String> queries = new HashMap<String, String>();
		queries.put("friends_invited_rsvp", "SELECT uid, rsvp_status FROM event_member WHERE eid = " + eid + " AND rsvp_status = 'attending'");
		queries.put("friends_invited_info", "SELECT uid, first_name, last_name, pic FROM user WHERE uid in (select uid from #friends_invited_rsvp)");

		MultiqueryResults multiqueryResult = client.executeMultiquery(queries, MultiqueryResults.class);
		
		for (int i=0; i<multiqueryResult.friends_invited_info.size(); i++) {
		
			Attending a = multiqueryResult.friends_invited_info.get(i);
			
			a.picture = a.pic;
			a.eid = eid_long;
			
			a.rsvp_status = multiqueryResult.friends_invited_rsvp.get(i).rsvp_status;
			
			if (a.rsvp_status.equals("unsure") || a.rsvp_status.equals("not_replied")) {
				
				a.rsvp_status = "maybe attending";
			} else if (a.rsvp_status.equals("declined")) {
				
				a.rsvp_status = "not attending";
			}
			
			result.add(a);
		}
 	
		return result;
			
	}
	
	public static void SetFacebookRsvp (String accessToken, String eid, String rsvp) {
		
		FacebookClient client	= new DefaultFacebookClient(accessToken);
		
		if (rsvp == "yes") {
			client.publish(eid + "/attending", FacebookType.class);
		} else if (rsvp == "no") {
			client.publish(eid + "/declined", FacebookType.class);
		} else {
			client.publish(eid + "/maybe", FacebookType.class);
		}
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
	
	public long getEid() {
		
		return this.eid;
	}
}
