package com.chaman.util;

import java.util.ArrayList;
import java.util.List;

import com.beoui.geocell.GeocellUtils;
import com.beoui.geocell.LocationCapableRepositorySearch;
import com.beoui.geocell.model.Point;
import com.chaman.model.Event;
import com.chaman.model.EventLocationCapable;
import com.chaman.model.User;

public class EventTools {

    private static final int[] NORTHEAST = new int[] {1,1};
    private static final int[] SOUTHWEST = new int[] {-1,-1};
	
	public static List<EventLocationCapable> proximityFetch(String searchLat, String searchLon, LocationCapableRepositorySearch<EventLocationCapable> ofySearch, float searchRadius) {
		
		List<EventLocationCapable> DS = new ArrayList<EventLocationCapable>();
		
		List<EventLocationCapable> result = new ArrayList<EventLocationCapable>();
		
		List<String> geocells = new ArrayList<String>();
		
		String mygeocell = GeocellUtils.compute(new Point(Double.parseDouble(searchLat), Double.parseDouble(searchLon)), 6);
		
		geocells = GeocellUtils.interpolate(GeocellUtils.adjacent(GeocellUtils.adjacent(mygeocell, NORTHEAST), NORTHEAST), GeocellUtils.adjacent(GeocellUtils.adjacent(mygeocell, SOUTHWEST), SOUTHWEST));
		
		DS = ofySearch.search(geocells);
		
		for (EventLocationCapable e : DS) {
			
			float distance = Geo.Fence(searchLat, searchLon, String.valueOf(e.getLatitude()), String.valueOf(e.getLongitude()));
			if (distance <= searchRadius) {
				
				result.add(e);
			}
			
		}
		
		return result;
	}
	
	
	public static List<Long> getELCkeys(List<EventLocationCapable> l){
		
		List<Long> result = new ArrayList<Long>();

		for (EventLocationCapable e : l) {
			
			result.add(e.getEid());
		}
		
		return result;
	}
	
	public static List<Long> getEventkeys(List<Event> l){
		
		List<Long> result = new ArrayList<Long>();

		for (Event e : l) {
			
			result.add(e.getEid());
		}
		
		return result;
	}
	
	public static List<Long> getUserkeys(ArrayList<User> l){
		
		List<Long> result = new ArrayList<Long>();

		for (User u : l) {
			
			result.add(u.getUid());
		}
		
		return result;
	}
	
}


