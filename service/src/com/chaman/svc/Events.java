package com.chaman.svc;

import java.util.ArrayList;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.Model;

public class Events extends ServerResource {

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
				
				events = Event.Get(accessToken, latitude, longitude, timeZone, Integer.parseInt(searchTimeFrame), Integer.parseInt(searchRadius), Integer.parseInt(searchLimit));
			}
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}