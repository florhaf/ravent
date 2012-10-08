package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.EventUser;
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
			String searchLat 		= getQuery().getValues("searchLat");
			String searchLon 		= getQuery().getValues("searchLon");
			String searchLimit 		= getQuery().getValues("limit");
			String locale	 		= getQuery().getValues("locale");
			String promoter	 		= getQuery().getValues("promoter");
			String is_chaman	 	= getQuery().getValues("is_chaman");
			
			String searchRadius = "6";
			
			if (searchLimit == null) {
				searchLimit = "0";
			}
			
			ArrayList<Model> events;
			
			if (userID != null) {
				if (promoter == null) {
					events = EventUser.Get(accessToken, userID, latitude, longitude, timeZone, locale);
				} else {
					events = EventUser.Get(accessToken, userID, latitude, longitude, timeZone, locale, true);
				}
			} else if (searchLat == null) {
				events = Event.Get(accessToken, latitude, longitude, latitude, longitude, timeZone, Integer.parseInt(searchTimeFrame), Float.parseFloat(searchRadius), Integer.parseInt(searchLimit), locale, is_chaman);
			} else {
				events = Event.Get(accessToken, latitude, longitude, searchLat, searchLon, timeZone, Integer.parseInt(searchTimeFrame), Float.parseFloat(searchRadius), Integer.parseInt(searchLimit), locale, is_chaman);
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