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
			String friendID		= getQuery().getValues("friendID");
			String eventID 		= getQuery().getValues("eventID");
			
			String res;
			
			res = Post.ShareEvent(accessToken, friendID, eventID);
			
			if (res != null) {
				// not invited but message posted on friend's timeline
				result.setSuccess(false);
				result.setError(res);
				return result;
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
