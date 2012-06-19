package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.Post;
import org.restlet.resource.ServerResource;

import com.chaman.model.Model;
import com.chaman.model.Picture;

public class Pictures extends ServerResource {

	@Get("json")
	public Response Read() {
		
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eid");
						
			ArrayList<Model> pictures = Picture.Get(accessToken, eventID);;
			
			result.setSuccess(true);
			result.setRecords(pictures);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
	
	@Post
	public void Post() {
		
	}
}