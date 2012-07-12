package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Description;
import com.chaman.model.Model;

public class Descriptions extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
		
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eventID 		= getQuery().getValues("eid");
			
			ArrayList<Model> descriptions = Description.Get(accessToken, eventID);
			
			result.setSuccess(true);
			result.setRecords(descriptions);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
