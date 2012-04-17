package com.chaman.svc;

import java.util.ArrayList;
import com.chaman.model.Model;

public class Response {
	
	Boolean				success;
	String				message;
	ArrayList<Model> 	records;
	
	public Response() {
		
		this.success = false;
		this.message = "";
		this.records = new ArrayList<Model>();
	}
	
	public Boolean getSuccess() {
		
		return success;
	}
	
	public void setSuccess(Boolean success) {
		
		if (success == true) {
			
			this.message = "OK";
		}
		
		this.success = success;
	}
	
	public String getMessage() {
		
		return message;
	}
	
	public void setMessage(String message) {
		
		this.message = message;
	}
	
	public ArrayList<Model> getRecords() {
		
		return records;
	}
	
	public void setRecords(ArrayList<Model> records) {
		
		this.records = records;
	}
}
