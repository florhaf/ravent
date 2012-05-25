package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Event;
import com.chaman.model.Model;

public class Calendar extends ServerResource {

	@Get("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String[] eids 		= getQuery().getValuesArray("eventID");
			String date			= getQuery().getValues("date");
			String timeZone		= getQuery().getValues("timezone_offset");
			String latitude		= getQuery().getValues("latitude");
			String longitude 	= getQuery().getValues("longitude");
			
			ArrayList<Model> events;
			
			events = Event.date(accessToken, eids, date, timeZone, latitude, longitude);
			
			result.setSuccess(true);
			result.setRecords(events);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
