package com.chaman.svc;

import java.util.logging.Logger;

import org.restlet.resource.Get;
import org.restlet.resource.ServerResource;

import com.chaman.model.Promoter;


public class Login extends ServerResource {

	private static final Logger log = Logger.getLogger(Login.class.getName());
	
	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID 		= getQuery().getValues("userID");
			String appuser		= getQuery().getValues("appuser");
			String isPromoter		= getQuery().getValues("isPromoter");
			
			if (isPromoter != null && !isPromoter.isEmpty())
				Promoter.Put(userID, userID, null, null, null);
						
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
