package com.chaman.svc;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;

public class EventBackends extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String options	= getQuery().getValues("options");

			if (options.equals("fetch")) {
				Event.GetCron();
			} else {
				Event.DeleteCron();
			}
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}
