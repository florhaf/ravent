package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Description;
import com.chaman.model.Model;

public class Descriptions extends ServerResource {

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
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
}
