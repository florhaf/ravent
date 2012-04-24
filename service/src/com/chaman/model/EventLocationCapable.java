package com.chaman.model;

import java.util.List;

import javax.persistence.Id;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.chaman.dao.Dao;
import com.googlecode.objectify.ObjectifyService;
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
    private double latitude;
    private double longitude;
    @Unindexed
    private int score;
    private List<String> geocells;
    private long creator; // promoter ID
    
	static {
		try {
			ObjectifyService.register(EventLocationCapable.class);
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}
    
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
    	this.creator = (event.creator != null) ? Long.parseLong(event.creator) : 0;
    	
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

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}
	
	public long getCreator() {
		return this.creator;
	}
	
	public void setCreator(long creator) {
		this.creator = creator;
	}
}
