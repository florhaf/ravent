package com.chaman.util;

import java.util.ArrayList;
import java.util.List;

import com.beoui.geocell.GeocellUtils;
import com.beoui.geocell.LocationCapableRepositorySearch;
import com.beoui.geocell.model.Point;
import com.chaman.model.Event;
import com.chaman.model.EventLocationCapable;
import com.chaman.model.Model;
import com.chaman.model.User;

public class EventTools {

    private static final int[] NORTHEAST = new int[] {1,1};
    private static final int[] SOUTHWEST = new int[] {-1,-1};
    
	public static List<EventLocationCapable> proximityFetch(String searchLat, String searchLon, LocationCapableRepositorySearch<EventLocationCapable> ofySearch, float searchRadius, int limit) {
		
		List<EventLocationCapable> DS = new ArrayList<EventLocationCapable>();
		
		List<EventLocationCapable> result = new ArrayList<EventLocationCapable>();
		
		List<String> geocells = new ArrayList<String>();
		
		String mygeocell = GeocellUtils.compute(new Point(Double.parseDouble(searchLat), Double.parseDouble(searchLon)), 6);
		
		geocells = GeocellUtils.interpolate(GeocellUtils.adjacent(GeocellUtils.adjacent(mygeocell, NORTHEAST), NORTHEAST), GeocellUtils.adjacent(GeocellUtils.adjacent(mygeocell, SOUTHWEST), SOUTHWEST));
		
		DS = ofySearch.search(geocells);
		
		int i = 0;
		
		for (EventLocationCapable e : DS) {
			
			float distance = Geo.Fence(searchLat, searchLon, String.valueOf(e.getLatitude()), String.valueOf(e.getLongitude()));
			if (distance <= searchRadius) {
				
				result.add(e);
				if (limit != 0) {
					i++;
					if (i >= limit) {
						break;
					}
				}
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


	public static List<Model> removeDuplicates(List<Model> l) {
		
		List<Model> result = new ArrayList<Model>();
		
		Event temp = null;
		
		for (int i = 0; i < l.size() -1; i++) {
			
			Event e1 = (Event) l.get(i);
			Event e2 = (Event) l.get(i + 1);
			
			//if same venue
			if ((e1.eventvenueID() != null && e2.eventvenueID() != null) && (e1.eventvenueID().equals(e2.eventvenueID()))) {
				
				//if event overlap (assuming same event)
				if (!(Long.parseLong(e1.starttime()) > Long.parseLong(e2.endtime()) || Long.parseLong(e2.starttime()) > Long.parseLong(e1.endtime()))) {
					
					if (e1.getOffer_title() != null || e1.getFeatured() != null || e1.getTicket_link() != null) {
						result.add(e1);
						continue;
					}
					
					//if e1 better than e2
					if (EventTools.is_better_than(e1, e2)) {
						
						if (temp != null) {
							
							if (EventTools.is_better_than(e1, temp)) {
								
								temp = e1;
							} // else temp stays the best
						} else {
							
							temp = e1;
						}
					} else {
						
						temp = e2;
					}
					continue;
				}
			} else {
				
				if (temp != null) {
					
					result.add(temp);
					temp = null;
				} else {
					
					result.add(e1);
				}
			}
			
		}
		
		//last one
		if (temp == null) {
			result.add((Event) l.get(l.size() - 1));
		} else {
			if (EventTools.is_better_than((Event) l.get(l.size() - 1), temp)) {
				result.add((Event) l.get(l.size() - 1));
			} else {
				result.add(temp);	
			}
		}
		
		return result;
	}


	private static boolean is_better_than(Event e1, Event e2) {
		
		Long c1 = Long.parseLong(e1.allMemberCount());
		Long c2 = Long.parseLong(e2.allMemberCount());
		
		if (c1 > c2) {
			return true;
		} else {
			return false;
		}
	}
}


