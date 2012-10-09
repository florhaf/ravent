package com.chaman.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import javax.persistence.Id;

import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.googlecode.objectify.annotation.Entity;

@Entity
public class VoteDetails extends Model {

	static {
		try {

			ObjectifyService.register(VoteDetails.class);
		} catch (Exception ex) {
			
			//System.out.println(ex.toString());
		}
	}
	
	@Id
	String eid;
	String uid;
	
	public VoteDetails () {
		
		super();
	}
	
	public VoteDetails (String eid, String uid) {
		
		try {
			
			Dao dao = new Dao();
			
			this.eid = eid;
			this.uid = uid;
			
			dao.ofy().put(this);
		} catch (Exception ex) {}
	}
	
	public ArrayList<Model> Raffle(String accessToken, String eid) {
		
		Dao dao = new Dao();
		
		Random r = new Random();
		
		Query<VoteDetails> qRaffle = dao.ofy().query(VoteDetails.class);
		List<VoteDetails> droppers = qRaffle.filter("eid", eid).list();
		 	
		VoteDetails winner = droppers.get(r.nextInt(droppers.size() - 1));
		
		return Profile.GetFacebookProfileInfo(accessToken, winner.uid);
	}

	public String getEid() {
		return eid;
	}

	public void setEid(String eid) {
		this.eid = eid;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

}
	
