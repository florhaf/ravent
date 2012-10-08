package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.EventMarketingProgram;
import com.chaman.model.Model;

public class EventMarketingPrograms extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Create(){
		
		Response result = new Response();
		
		try {
			
			String eid = getQuery().getValues("eid");
			String userID = getQuery().getValues("userID");
			String accessToken = getQuery().getValues("access_token");
			String features = getQuery().getValues("features");
			String title = getQuery().getValues("title");
			String terms = getQuery().getValues("terms");
			String ticket_link = getQuery().getValues("ticket_link");
			String timeZone = getQuery().getValues("timezone_offset");
			
			ArrayList<Model> emp_res = EventMarketingProgram.PutEventMarketingProgram(userID, accessToken, Long.valueOf(eid), features, title, terms, ticket_link, timeZone);
			
			result.setSuccess(true);
			result.setRecords(emp_res);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}	
}
