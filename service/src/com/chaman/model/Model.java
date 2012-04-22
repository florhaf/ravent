package com.chaman.model;

import java.util.logging.Logger;
import javax.persistence.Transient;

public abstract class Model {

	protected static final Logger log = Logger.getLogger(Model.class.getName());
	@Transient
	protected int ID;
	
	public Model() {
		
	}
	
	public int getID() {
		return ID;
	}

	public void setID(int iD) {
		ID = iD;
	}
}
