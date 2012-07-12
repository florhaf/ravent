package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.Model;

public class Events extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken		= getQuery().getValues("access_token");
			String userID 			= getQuery().getValues("userID");
			String latitude 		= getQuery().getValues("latitude");
			String longitude 		= getQuery().getValues("longitude");
			String timeZone 		= getQuery().getValues("timezone_offset");
			String searchTimeFrame 	= getQuery().getValues("timeframe");
			String searchRadius		= getQuery().getValues("radius");
			String searchLimit 		= getQuery().getValues("limit");
			
			searchLimit = "100";
			
			ArrayList<Model> events;
			
			if (userID != null) {
			
				events = Event.Get(accessToken, userID, latitude, longitude, timeZone);
			} else {
				
				events = Event.Get(accessToken, latitude, longitude, timeZone, Integer.parseInt(searchTimeFrame), Float.parseFloat(searchRadius), Integer.parseInt(searchLimit));
			}
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}