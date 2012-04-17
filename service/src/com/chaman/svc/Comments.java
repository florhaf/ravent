package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Comment;
import com.chaman.model.Model;

public class Comments extends ServerResource {

	@Get("json")
	public Response Read() {
		
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eid");
						
			ArrayList<Model> comments = Comment.Get(accessToken, eventID);;
			
			result.setSuccess(true);
			result.setRecords(comments);
			
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
			String eventID 		= getQuery().getValues("eid");
			String message		=getQuery().getValues("message");
			
			Comment.Put(accessToken, eventID, message);
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
