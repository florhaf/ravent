package com.chaman.svc;

import java.util.ArrayList;

import org.restlet.resource.Delete;
import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.restlet.resource.ServerResource;

import com.chaman.model.Following;
import com.chaman.model.Model;

public class Followings extends ServerResource {

	@Get("json")
	public Response Read() {
				
		Response result = new Response();
		
		try {
			
			String accessToken	= getQuery().getValues("access_token");
			String userID		= getQuery().getValues("userID");
			String isFollowing	= getQuery().getValues("isFollowing");
			
			ArrayList<Model> followings = com.chaman.model.Following.Get(accessToken, userID, Boolean.valueOf(isFollowing));
						
			result.setSuccess(true);
			result.setRecords(followings);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
	
	@Put("json")
	public Response Create() {
				
		Response result = new Response();
		
		try {
			
			String userID 		= getQuery().getValues("userID");
			String friendID		= getQuery().getValues("friendID");
			
			com.chaman.model.Following.Put(userID, friendID);
						
			Following f = new Following();
			f.setUserID(Long.parseLong(userID));
			f.setFriendID(Long.parseLong(friendID));
			
			ArrayList<Model> records = new ArrayList<Model>();
			records.add(f);
			
			result.setSuccess(true);
			result.setRecords(records);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}
	
	@Delete("json")
	public Response Delete() {
				
		Response result = new Response();
		
		try {
			
			String userID 		= getQuery().getValues("userID");
			String friendID		= getQuery().getValues("friendID");
			
			com.chaman.model.Following.Delete(userID, friendID);
						
			Following f = new Following();
			f.setUserID(Long.parseLong(userID));
			f.setFriendID(Long.parseLong(friendID));
			
			ArrayList<Model> records = new ArrayList<Model>();
			records.add(f);
			
			result.setSuccess(true);
			result.setRecords(records);
			
		} catch (Exception ex) {
			
			result.setSuccess(false);
			result.setMessage(ex.toString());
		}
		
		return result;
	}

}
