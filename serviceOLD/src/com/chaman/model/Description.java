package com.chaman.model;

import java.util.ArrayList;
import java.util.List;

import com.restfb.DefaultFacebookClient;
import com.restfb.Facebook;
import com.restfb.FacebookClient;
import com.restfb.exception.FacebookException;

public class Description extends Model {

	@Facebook
	int eid;
	@Facebook
	String description;
	
	public static ArrayList<Model> Get(String accessToken, String eventID) throws FacebookException {
		
		ArrayList<Model> result = new ArrayList<Model>();
		
		FacebookClient client 	= new DefaultFacebookClient(accessToken);
		String properties 		= "description";
		String query 			= "SELECT " + properties + " FROM event WHERE eid = '" + eventID + "'";
		List<Description> descriptions 	= client.executeQuery(query, Description.class);
		
		for (Description d : descriptions) {
			
			//d.description = d.description.replace("\n", "<br />");
			
			result.add(d);
		}
 	
		return result;
	}
	
	public int getEid() {
		
		return this.eid;
	}
	
	public String getDescription() {
		
		return this.description;
	}
}
