package com.chaman.util;

import java.util.Comparator;

import com.chaman.model.EventLocationCapable;
import com.chaman.model.Model;

public class EventLocationCapableComparator implements Comparator<Model>{

	@Override
	public int compare(Model o1, Model o2) {
		
		int res = 0;
		
		EventLocationCapable e1 = (EventLocationCapable ) o1;
		EventLocationCapable  e2 = (EventLocationCapable ) o2;

		Double Diff = (e1.getLongitude() + e1.getLatitude()) - (e2.getLongitude() + e2.getLatitude());
	        
		res = (Diff > 0 ? 1 : (Diff == 0 ? 0 : -1));		
		
		if (res == 0) {
			
			Long Difftime_start = e1.getTimeStampStart() - e2.getTimeStampStart();
			res = (Difftime_start > 0 ? 1 : (Diff == 0 ? 0 : -1));
		}
		
		return res;
	}
}



