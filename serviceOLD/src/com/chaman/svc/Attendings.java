package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Attending;
import com.chaman.model.Model;

public class Attendings extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String eid			= getQuery().getValues("eid");
			
			ArrayList<Model> attendings = Attending.Get(accessToken, userID, eid);
						
			result.setSuccess(true);
			result.setRecords(attendings);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}

}
