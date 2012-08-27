package com.chaman.util;

import java.util.Comparator;

import com.chaman.model.Event;
import com.chaman.model.Model;

public class EventComparator implements Comparator<Model>{

	@Override
	public int compare(Model o1, Model o2) {
		
		int res = 0;
		
		Event e1 = (Event) o1;
		Event e2 = (Event) o2;
		
		if (e1.eventvenueID() == null || e2.eventvenueID() == null) {return 0;}
		if (e1.eventvenueID() != null && e2.eventvenueID() == null) {return 1;}
		if (e1.eventvenueID() == null && e2.eventvenueID() != null) {return -1;}

		Long Diff = Long.valueOf(e1.eventvenueID()) - Long.valueOf(e2.eventvenueID());
	        
		res = (Diff > 0 ? 1 : (Diff == 0 ? 0 : -1));		
		
		if (res == 0) {
			
			Long Difftime_start = Long.valueOf(e1.starttime()) - Long.valueOf(e2.starttime());
			res = (Difftime_start > 0 ? 1 : (Diff == 0 ? 0 : -1));
		}
		
		return res;
	}
}



