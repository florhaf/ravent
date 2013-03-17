package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Post;
import org.restlet.resource.Put;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Attending;
import com.chaman.model.Model;

public class Rsvp extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String uid 			= getQuery().getValues("userID");
			String eid			= getQuery().getValues("eventID");
			
			ArrayList<Model> rsvp_status = Attending.GetFacebookRsvp(accessToken, uid, eid);
			
			result.setSuccess(true);
			result.setRecords(rsvp_status);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

	
	@Put("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eventID");
			String rsvp			= getQuery().getValues("rsvp");
			
			Attending.SetFacebookRsvp(accessToken, eventID, rsvp);
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
	
	@Post("json")
	public Response Create2() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eventID");
			String rsvp			= getQuery().getValues("rsvp");
			
			Attending.SetFacebookRsvp(accessToken, eventID, rsvp);
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
