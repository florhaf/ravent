package com.chaman.svc;

import java.util.ArrayList;
import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.EventMarketingProgram;
import com.chaman.model.Model;

public class EventMarketingPrograms extends ServerResource {

	private static final Logger log = Logger.getLogger(Events.class.getName());
	
	@Get("json")
	public Response Read() {
		
		Response result = new Response();
		
		try {
			
			String eid = getQuery().getValues("eid");
			
			ArrayList<Model> emp_res = EventMarketingProgram.GetEventMarketingProgram(Long.valueOf(eid));
			
			result.setSuccess(true);
			result.setRecords(emp_res);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}	
	
	@Put("json")
	public Response Create(){
		
		Response result = new Response();
		
		try {
			
			String eid = getQuery().getValues("eid");
			String features = getQuery().getValues("features");
			String title = getQuery().getValues("title");
			String terms = getQuery().getValues("terms");
			String ticket_link = getQuery().getValues("ticket_link");
			
			ArrayList<Model> emp_res = EventMarketingProgram.PutEventMarketingProgram(Long.valueOf(eid), features, title, terms, ticket_link);
			
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
