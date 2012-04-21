package com.chaman.svc;

import java.util.ArrayList;
import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;
import com.chaman.model.Event;
import com.chaman.model.Model;

public class EventDetails extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String eid 		= getQuery().getValues("eid");

			ArrayList<Model> e;
			
			e = Event.getNb_invited(accessToken, eid);
			
			result.setSuccess(true);
			result.setRecords(e);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}

}
