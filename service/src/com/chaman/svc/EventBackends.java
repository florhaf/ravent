package com.chaman.svc;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;

public class EventBackends extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			//String options	= getQuery().getValues("options");

			Event.GetCron();
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}

}
