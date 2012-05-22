package com.chaman.svc;

import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Post;

public class Share extends ServerResource {

	@Put("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String friendID		= getQuery().getValues("friendid");
			String eventID 		= getQuery().getValues("eid");
			
			Post.ShareEvent(accessToken, friendID, eventID);
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}