package com.chaman.svc;

import java.util.ArrayList;
import java.util.Date;
import java.util.logging.Logger;

import org.joda.time.DateTime;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.Model;

public class Events extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		
		log.severe("START");
		
		
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
			
			searchLimit = "200";
			String searchRadius = "6";
			
			ArrayList<Model> events;
			
			
			
			if (userID != null) {
			
				events = Event.Get(accessToken, userID, latitude, longitude, timeZone, locale);
			} else {
				if (searchLat == null) {
					events = Event.Get(accessToken, latitude, longitude, latitude, longitude, timeZone, Integer.parseInt(searchTimeFrame), Float.parseFloat(searchRadius), Integer.parseInt(searchLimit), locale);
				} else {
					events = Event.Get(accessToken, latitude, longitude, searchLat, searchLon, timeZone, Integer.parseInt(searchTimeFrame), Float.parseFloat(searchRadius), Integer.parseInt(searchLimit), locale);
				}
				
				
			}
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		log.severe("END");
		
		return result;
	}

}