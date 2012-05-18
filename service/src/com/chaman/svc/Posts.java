package com.chaman.svc;

import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Post;

import org.restlet.representation.*;

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
			
			if (eventID == null) {
				Post.FriendWallPost(accessToken, friendID, message);
			} else {
				Post.EventPost(accessToken, userID, eventID, message);
			}
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
	
	@Put
	public Response Create(Representation representation) {
		
		Response result = new Response();

		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID		= getQuery().getValues("userid");
			String friendID		= getQuery().getValues("friendid");
			String eventID 		= getQuery().getValues("eid");
			String message		= getQuery().getValues("message");
			
			//get attachment from header (encoded URL form)
			String attachment	= representation.getText();
			
			if (eventID == null) {
				Post.FriendWallPostWithAttachment(accessToken, friendID, attachment, message);
			} else {
				Post.EventPostWithAttachment(accessToken, userID, eventID, attachment, message);
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
