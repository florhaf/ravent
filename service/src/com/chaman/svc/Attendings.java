package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Attending;
import com.chaman.model.Model;

public class Attendings extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String eid			= getQuery().getValues("eid");
			
			ArrayList<Model> attendings;
			
			if (userID != null) {
				attendings = Attending.GetInvitedFriendsList(accessToken, userID, eid);
			} else {
				attendings = Attending.GetAttendingAllList(accessToken, eid);
			}
			result.setSuccess(true);
			result.setRecords(attendings);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}

}
