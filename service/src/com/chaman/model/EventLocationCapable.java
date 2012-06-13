package com.chaman.model;

import java.util.List;

import javax.persistence.Id;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.chaman.dao.Dao;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Unindexed;

/*
 * event object we store in our DB
 */
@Entity
public class EventLocationCapable extends Model implements LocationCapable {

	@Id
	private long eid;
	private long timeStampStart;
	private long timeStampEnd;
	@Unindexed
    private double latitude;
	@Unindexed
    private double longitude;
    @Unindexed
    private double score;
    private List<String> geocells;
    
	public EventLocationCapable() {
		
		super();
	}
	
    public EventLocationCapable(Event event) {
    	
    	this.eid = event.eid;
    	this.timeStampStart = Long.parseLong(event.start_time);
    	this.timeStampEnd = Long.parseLong(event.end_time);
    	this.latitude = Double.parseDouble(event.latitude);
    	this.longitude = Double.parseDouble(event.longitude);
    	this.score = event.score;
    	
    	geocells = GeocellManager.generateGeoCell(this.getLocation());
    }
    
    public void Save() {
    	
    	Dao dao = new Dao();
    	
    	dao.ofy().put(this);
    }
    
    public double getLatitude() {
    	
        return latitude;
    }

    public void setLatitude(double latitude) {
    	
        this.latitude = latitude;
    }

    public double getLongitude() {
    	
        return longitude;
    }

    public void setLongitude(double longitude) {
    	
        this.longitude = longitude;
    }

    public List<String> getGeocells() {
    	
        return geocells;
    }

    public void setGeocells(List<String> geocells) {
    	
        this.geocells = geocells;
    }

    public String getKeyString() {
    	
        return Long.valueOf(eid).toString();
    }

    public Point getLocation() {
    	
        return new Point(latitude, longitude);
    }

	public long getEid() {
		return eid;
	}

	public void setEid(long eid) {
		this.eid = eid;
	}

	public long getTimeStampStart() {
		return timeStampStart;
	}

	public void setTimeStampStart(long timeStampStart) {
		this.timeStampStart = timeStampStart;
	}

	public long getTimeStampEnd() {
		return timeStampEnd;
	}

	public void setTimeStampEnd(long timeStampEnd) {
		this.timeStampEnd = timeStampEnd;
	}

	public double getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}
}
