package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Friend;
import com.chaman.model.Model;

public class Friends extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			
			ArrayList<Model> friends = Friend.Get(accessToken, userID);
						
			result.setSuccess(true);
			result.setRecords(friends);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
