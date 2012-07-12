package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Model;
import com.chaman.model.User;


public class Users extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String appuser		= getQuery().getValues("appuser");
			
			ArrayList<Model> users = User.Get(accessToken, userID, appuser);
						
			result.setSuccess(true);
			result.setRecords(users);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
