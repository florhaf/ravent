package com.chaman.svc;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.EventFetchCron;

public class EventBackends extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String options	= getQuery().getValues("options");

			if (options.equals("fetch")) {
				EventFetchCron.GetCron();
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
