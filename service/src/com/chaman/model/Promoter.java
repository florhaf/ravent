package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.googlecode.objectify.annotation.NotSaved;
import com.googlecode.objectify.annotation.Unindexed;
import com.restfb.DefaultFacebookClient;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class Promoter extends Model{
	
	@Id
	String other_id; //page id or user id (unique)
	String pid; // person promoting is own event or a page event
	@Unindexed
	int Nb_featured;
	@Unindexed
	int Nb_tickets;
	@Unindexed
	int Nb_rafles;
	@Unindexed
	int Nb_gems;
	@Unindexed
	int Nb_goodies;
	@NotSaved
	String pid_name;
	@NotSaved
	String pid_pic;
	@NotSaved
	String other_id_name;
	@NotSaved
	String other_id_pic;
	
	static {
		try {

			ObjectifyService.register(Promoter.class);
		} catch (Exception ex) {
			
			//System.out.println(ex.toString());
		}
	}
	
	public Promoter() {
		super();
	}
	
	public Promoter(String pid, String other_id) {
		
		this.pid = pid;
		this.other_id = other_id;
	}
	
	public static ArrayList<Model> Get(String pid, String accessToken, boolean isConsolidated) throws FacebookException {
		
		ArrayList<Model> result = new ArrayList<Model>();
 	
		Promoter p_consolidated = new Promoter();
		
		Dao dao = new Dao();
		
		Query<Promoter> qPromoter = dao.ofy().query(Promoter.class);
		qPromoter.filter("pid", pid);
		
		ArrayList<Model> profile_pid = Profile.GetFacebookProfileInfo(accessToken, pid);	
		Profile p_pid = null;
		
		if (profile_pid != null && !profile_pid.isEmpty()) {
			
			p_pid = (Profile) profile_pid.get(0);
		}

		for (Promoter p : qPromoter) {
			
			if (!isConsolidated) {
				
				ArrayList<Model> profile_other_id = Profile.GetFacebookProfileInfo(accessToken, p.other_id);
				
				if (profile_other_id != null &&!profile_other_id.isEmpty()) {
					
					Profile p_other_id = (Profile) profile_other_id.get(0);
					p.other_id_name = p_other_id.name;
					p.other_id_pic = p_other_id.pic;
				}
				
				if (p_pid != null) {
					
					p.pid_name = p_pid.name;
					p.pid_pic = p_pid.pic;
				}
				
				result.add(p);
			} else {
				
				p_consolidated.Nb_featured = p_consolidated.Nb_featured + p.Nb_featured;
				p_consolidated.Nb_tickets = p_consolidated.Nb_tickets + p.Nb_tickets;
				p_consolidated.Nb_rafles = p_consolidated.Nb_rafles + p.Nb_rafles;
				p_consolidated.Nb_gems = p_consolidated.Nb_gems + p.Nb_gems;
				p_consolidated.Nb_goodies = p_consolidated.Nb_goodies + p.Nb_goodies;
			}
		}
		
		if (isConsolidated) {
			
			if (p_pid != null) {
				
				p_consolidated.pid_name = p_pid.name;
				p_consolidated.pid_pic = p_pid.pic;
			}
			
			result.add(p_consolidated);
		}
		
		return result;
	}

	public static void Put(String pid, String other_id, String features, String title, String ticket_link) {
		
		Dao dao = new Dao();
		
		if (other_id != null) {
		
	        Promoter p = dao.ofy().find(Promoter.class, other_id);
	        
	        if (p == null) {
	        
	        	p = new Promoter(pid, other_id);
	        	p.Nb_gems = 0;
	        	p.Nb_featured = features != null && features.contains("P") ? 1 : 0;
	        	p.Nb_rafles = features != null && features.contains("RAF") ? 1 : 0;
	        	p.Nb_tickets = ticket_link != null ? 1 : 0;
	        	p.Nb_goodies = title != null ? 1 : 0;
	        } else {

	        	p.Nb_featured = features != null && features.contains("P") ? p.Nb_featured++ : p.Nb_featured;
	        	p.Nb_rafles = features != null && features.contains("RAF") ? p.Nb_rafles++ : p.Nb_rafles;
	        	p.Nb_tickets = ticket_link != null ? p.Nb_tickets++ : p.Nb_tickets;
	        	p.Nb_goodies = title != null ? p.Nb_goodies++ : p.Nb_goodies;
	        }
			
			dao.ofy().put(p);
		}
	}

	public static void AddVote(String eid, String accessToken) {
		
		try {
			
			FacebookClient client 	= new DefaultFacebookClient(accessToken);
			String query 			= "SELECT creator FROM event WHERE eid = " + eid;
			List<Event> fbevents 	= client.executeQuery(query, Event.class); //TODO: Use Batch
			
			Dao dao = new Dao();
			
			if (fbevents != null) {
			
		        Promoter p = dao.ofy().find(Promoter.class, fbevents.get(0).creator);
		        
		        if (p != null) {
		        	
		        	p.Nb_gems++;
					dao.ofy().put(p);
		        }
			}
		} catch (Exception ex) {}
		
	}

	public String getOther_id() {
		return other_id;
	}

	public void setOther_id(String other_id) {
		this.other_id = other_id;
	}

	public String getPid() {
		return pid;
	}

	public void setPid(String pid) {
		this.pid = pid;
	}

	public int getNb_featured() {
		return Nb_featured;
	}

	public void setNb_featured(int nb_featured) {
		Nb_featured = nb_featured;
	}

	public int getNb_tickets() {
		return Nb_tickets;
	}

	public void setNb_tickets(int nb_tickets) {
		Nb_tickets = nb_tickets;
	}

	public int getNb_rafles() {
		return Nb_rafles;
	}

	public void setNb_rafles(int nb_rafles) {
		Nb_rafles = nb_rafles;
	}

	public int getNb_gems() {
		return Nb_gems;
	}

	public void setNb_gems(int nb_gems) {
		Nb_gems = nb_gems;
	}

	public int getNb_goodies() {
		return Nb_goodies;
	}

	public void setNb_goodies(int nb_goodies) {
		Nb_goodies = nb_goodies;
	}

	public String getPid_name() {
		return pid_name;
	}

	public void setPid_name(String pid_name) {
		this.pid_name = pid_name;
	}

	public String getPid_pic() {
		return pid_pic;
	}

	public void setPid_pic(String pid_pic) {
		this.pid_pic = pid_pic;
	}

	public String getOther_id_name() {
		return other_id_name;
	}

	public void setOther_id_name(String other_id_name) {
		this.other_id_name = other_id_name;
	}

	public String getOther_id_pic() {
		return other_id_pic;
	}

	public void setOther_id_pic(String other_id_pic) {
		this.other_id_pic = other_id_pic;
	}
	
}
