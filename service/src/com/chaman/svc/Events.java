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
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String latitude 	= getQuery().getValues("latitude");
			String longitude 	= getQuery().getValues("longitude");
			String timeZone 	= getQuery().getValues("timezone_offset");
			
			// TODO: get from query string
			String searchTimeFrame = "48";
			String searchRadius = "30";
			String searchLimit = "30";
			
			ArrayList<Model> events;
			
			Event.GetCron();
			
			if (userID != null) {
			
				events = Event.Get(accessToken, userID, latitude, longitude, timeZone);
			} else {
				
				events = Event.Get(accessToken, latitude, longitude, timeZone, Integer.parseInt(searchTimeFrame), Integer.parseInt(searchRadius), Integer.parseInt(searchLimit));
			}
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}

}
