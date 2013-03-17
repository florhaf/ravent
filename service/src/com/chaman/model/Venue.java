package com.chaman.model;

import java.util.List;

import com.chaman.util.JSON;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class Venue  extends Model {

	@Facebook
	String page_id;
	@Facebook
	String category; // old to delete
	@Facebook
	String categories;
	@Facebook
	String checkins;
	@Facebook
	String talking_about_count;
	@Facebook("fan_count")
	String likes;
	@Facebook
	String location;
	@Facebook
	String name;
	
	public Venue() {
		
		super();
	}
	
	public static Venue getVenue(FacebookClient client, String venueID, Event e) throws FacebookException {
		
		Venue result = new Venue();
		
		if (venueID != null) {
			try {
				
				String query 			= "SELECT page_id, checkins, talking_about_count, fan_count, location, categories FROM page WHERE page_id = " + venueID;;
				List<Venue> fbevents 	= client.executeQuery(query, Venue.class);
			
				if (fbevents != null && fbevents.size() > 0) {
					
					result = fbevents.get(0);
					result.category = JSON.GetCategories("name", fbevents.get(0).categories);
					
					e.address = JSON.GetValueFor("street", result.location) + " " +
							JSON.GetValueFor("city", result.location) + " " +
							JSON.GetValueFor("state", result.location) + " " +
							JSON.GetValueFor("zip", result.location) + " " +
							JSON.GetValueFor("country", result.location);
					e.address = e.address.replaceAll("  ", " ");
				}
			} catch (Exception ex) {
				
				
			}
		}
		return result;
	}

	public String getPage_id() {
		return page_id;
	}

	public void setPage_id(String page_id) {
		this.page_id = page_id;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getCategories() {
		return categories;
	}

	public void setCategories(String categories) {
		this.categories = categories;
	}

	public String getCheckins() {
		return checkins;
	}

	public void setCheckins(String checkins) {
		this.checkins = checkins;
	}

	public String getTalking_about_count() {
		return talking_about_count;
	}

	public void setTalking_about_count(String talking_about_count) {
		this.talking_about_count = talking_about_count;
	}

	public String getLikes() {
		return likes;
	}

	public void setLikes(String likes) {
		this.likes = likes;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
