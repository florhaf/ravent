package com.chaman.util;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import com.beoui.geocell.GeocellUtils;
import com.beoui.geocell.LocationCapableRepositorySearch;
import com.beoui.geocell.model.Point;
import com.chaman.dao.Dao;
import com.chaman.model.Event;
import com.chaman.model.EventLocationCapable;
import com.chaman.model.EventMarketingProgram;
import com.chaman.model.Model;
import com.chaman.model.User;

public class EventTools {

	protected static final Logger log = Logger.getLogger(EventTools.class.getName());
	
    private static final int[] NORTHEAST = new int[] {1,1};
    private static final int[] SOUTHWEST = new int[] {-1,-1};
    
	public static List<EventLocationCapable> proximityFetch(String searchLat, String searchLon, LocationCapableRepositorySearch<EventLocationCapable> ofySearch, float searchRadius, int limit, long actual_time) {
		
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
				
				
		    	if (actual_time > e.getTimeStampEnd() || (((e.getTimeStampEnd() - e.getTimeStampStart()) / 86400) > 62)) { //if past or lenth > 62days
		    		continue;
		    	}
		 			
				result.add(e);
				if (limit != 0) {
					i++;
					if (i >= limit) {
						break;
					}
				}
			}
			
		}
		
		/*Collections.sort(result, new EventLocationCapableComparator());
		log.severe("PROXYFETCH - after sort = " + result.size());
		
		result = removeDuplicates_in_proximityFetch(result);
		log.severe("PROXYFETCH - after rem duplicate = " + result.size());*/
		
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
		
		if (l != null && l.size() > 0) {
			
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
		}
		
		return result;	
	}


public static List<EventLocationCapable> removeDuplicates_in_proximityFetch(List<EventLocationCapable> l) {
		
		List<EventLocationCapable> result = new ArrayList<EventLocationCapable>();
		
		if (l != null && l.size() > 0) {
			
			EventLocationCapable isfirst = null;
			
			for (int i = 0; i < l.size() -1; i++) {
				
				EventLocationCapable e1 = (EventLocationCapable) l.get(i);
				EventLocationCapable e2 = (EventLocationCapable) l.get(i + 1);
				

				//if same venue
				if (is_same_venue(e1, e2)) {
					
					//if event overlap (assuming same event)
					if (!(e1.getTimeStampStart() > e2.getTimeStampEnd() || e2.getTimeStampStart() > e1.getTimeStampEnd())) {
						
						//TODO to remove after implementation of second fetch for featured events
						
						/* Get information from DS concerning Marketing Programs
						*/
						Dao dao = new Dao();
						EventMarketingProgram emp = dao.ofy().find(EventMarketingProgram.class, e1.getEid());
						
						if (emp != null) {
							
							result.add(e1);
							isfirst = e1;
							continue;
						}
						
						if (isfirst == null) {
							
							isfirst = e1;
							result.add(e1);
							continue;
						} else {
							
							if (is_same_venue(e1, isfirst)) {
								
								i++;
								continue;
							} else {
								
								isfirst = e1;
								result.add(e1);
								i++;
								continue;
							}
						}
					}
				}
				
				result.add(e1);
				result.add(e2);
				isfirst = e2;
				i++;
			}		
		}
		
		return result;	
	}
	
	private static boolean is_same_venue (EventLocationCapable e1, EventLocationCapable e2) {
		
		if (e1.getLatitude() == e2.getLatitude() && e1.getLongitude() == e2.getLongitude()) {
		
			return true;
		}
		
		return false;
	}

	private static boolean is_better_than(Event e1, Event e2) {
		
		if (e1.allMemberCount() != null && e2.allMemberCount() != null) {
			
			Long c1 = Long.parseLong(e1.allMemberCount());
			Long c2 = Long.parseLong(e2.allMemberCount());
			
			if (c1 != null && c2 != null) {
			
				if (c1 > c2) {
					return true;
				} else {
					return false;
				}
			}
		}
		
		if (e1.allMemberCount() == null) {
			return false;
		}
		if (e2.allMemberCount() == null) {
			return true;
		}
		
		return true;
	}
}


