package com.chaman.svc;

import java.util.ArrayList;
import com.chaman.model.Model;

public class Response {
	
	Boolean				success;
	String				error;
	ArrayList<Model> 	records;
	
	public Response() {
		
		this.success = false;
		this.error = "";
		this.records = new ArrayList<Model>();
	}
	
	public Boolean getSuccess() {
		
		return success;
	}
	
	public void setSuccess(Boolean success) {
		
		if (success == true) {
			
			this.error = null;
		}
		
		this.success = success;
	}
	
	public String getError() {
		
		return error;
	}
	
	public void setError(String error) {
		
		this.error = error;
	}
	
	public ArrayList<Model> getRecords() {
		
		return records;
	}
	
	public void setRecords(ArrayList<Model> records) {
		
		this.records = records;
	}
}
