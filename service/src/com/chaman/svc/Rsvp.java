package com.chaman.svc;

import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Attending;

public class Rsvp extends ServerResource {

	@Put("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eid");
			String rsvp			= getQuery().getValues("rsvp");
			
			Attending.SetFacebookRsvp(accessToken, eventID, rsvp);
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
