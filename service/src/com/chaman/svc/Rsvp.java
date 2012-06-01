package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Put;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Attending;
import com.chaman.model.Model;

public class Rsvp extends ServerResource {

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
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
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
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
