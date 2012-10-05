package com.chaman.svc;

import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Vote;

public class Votes extends ServerResource {

	@Put("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userid	= getQuery().getValues("userID");
			String eid 		= getQuery().getValues("eventID");
			String vote		= getQuery().getValues("vote");
			
			new Vote(accessToken, userid, eid, vote, false, "Dropped a gem on this event with Gemster");
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
