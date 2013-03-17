package com.chaman.svc;

import org.restlet.resource.Post;
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
			
			new Vote(accessToken, userid, eid, vote, false, "Dropped a Gem on this event to spread the word");
			
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
			String userid	= getQuery().getValues("userID");
			String eid 		= getQuery().getValues("eventID");
			String vote		= getQuery().getValues("vote");
			
			new Vote(accessToken, userid, eid, vote, false, "Dropped a Gem on this event to spread the word");
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
