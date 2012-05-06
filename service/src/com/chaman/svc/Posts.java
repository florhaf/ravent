package com.chaman.svc;

import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Post;

public class Posts extends ServerResource {

	@Put("json")
	public Response Create() {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID		= getQuery().getValues("userid");
			String friendID		= getQuery().getValues("friendid");
			String eventID 		= getQuery().getValues("eid");
			String message		= getQuery().getValues("message");
			String attachement	= getQuery().getValues("attachement");
			
			if (eventID == null) {
				Post.FriendWallPost(accessToken, friendID, message);
			} else {
				Post.EventPost(accessToken, userID, eventID, attachement, message);
			}
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
