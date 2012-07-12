package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.Post;
import org.restlet.resource.ServerResource;

import com.chaman.model.Model;
import com.chaman.model.Picture;

public class Pictures extends ServerResource {
	
	private static final Logger log = Logger.getLogger(Events.class.getName());

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
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
	
	@Post
	public void Post() {
		
	}
}