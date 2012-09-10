package com.chaman.svc;

import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Visibility;

public class GemsterVisibility extends ServerResource {

	private static final Logger log = Logger.getLogger(GemsterVisibility.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String latitude 	= getQuery().getValues("latitude");
			String longitude 	= getQuery().getValues("longitude");
			String max_post 	= getQuery().getValues("maxPost");
			String min_score 	= getQuery().getValues("minScore");
			
			Visibility hack = new Visibility(userID, accessToken, latitude, longitude, Integer.parseInt(max_post), Integer.parseInt (min_score));
						
			log.info(hack.getNbVote() + "/" + hack.getEvent_list_size());
			
			result.setSuccess(true);
			result.setRecords(null);
			
		} catch (Exception ex) {
			
			log.severe(ex.toString());
			
			result.setSuccess(false);
			result.setError(ex.toString());
		}
		
		return result;
	}
}
