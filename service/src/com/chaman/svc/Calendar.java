package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.data.Form;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Event;
import com.chaman.model.Model;

public class Calendar extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			//version 1 
			
			String accessToken	= getQuery().getValues("access_token");
			String[] eids 		= getQuery().getValuesArray("eventID");
			String timeZone		= getQuery().getValues("timezone_offset");
			String latitude		= getQuery().getValues("latitude");
			String longitude 	= getQuery().getValues("longitude");
			String locale 		= getQuery().getValues("locale");
			String is_chaman	 = getQuery().getValues("is_chaman");
			
			ArrayList<Model> events;
			
			events = Event.getMultiple(accessToken, eids, timeZone, latitude, longitude, locale, is_chaman);
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
	
	@org.restlet.resource.Post()
	public Response Create(Form form) {
		
		Response result = new Response();

		try {
					
			
			//new version
			
			String accessToken	= getQuery().getValues("access_token");
			String[] eids 		= form.getValues("eid").split(",");
			String timeZone		= getQuery().getValues("timezone_offset");
			String latitude		= getQuery().getValues("latitude");
			String longitude 	= getQuery().getValues("longitude");
			String locale 		= getQuery().getValues("locale");
			String is_chaman	 = getQuery().getValues("is_chaman");
			
			ArrayList<Model> events;
			
			events = Event.getMultiple(accessToken, eids, timeZone, latitude, longitude, locale, is_chaman);
			
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
