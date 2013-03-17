package com.chaman.svc;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.EventFetchCron;
import com.chaman.model.Notification;

public class EventBackends extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String options	= getQuery().getValues("options");	
			
			if (options.equals("notify_access_exp")) {
				Notification.Notify_access_exp();
			}
			else if (options.equals("fetch")) {
				EventFetchCron.GetCron();
			}
			else if (options.equals("delete")) {
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
