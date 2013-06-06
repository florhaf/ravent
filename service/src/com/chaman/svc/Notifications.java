package com.chaman.svc;

import org.restlet.resource.ServerResource;

import com.chaman.model.Notification;

public class Notifications extends ServerResource {
	
	@org.restlet.resource.Post("json")
	public Response Create() {
		
		Response result = new Response();
		
		try {
			
			Notification.Notify_access_exp();

			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
	
}
