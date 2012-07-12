package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Attending;
import com.chaman.model.Model;

public class EventStats extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken		= getQuery().getValues("access_token");
			String eid 				= getQuery().getValues("eid");
			
			ArrayList<Model> events = new ArrayList<Model>();
			
			events.add(Attending.GetNb_attending_and_gender_ratio(accessToken, eid));
			
			result.setSuccess(true);
			result.setRecords(events.get(0) == null ? null : events);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}
