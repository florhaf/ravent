package com.chaman.model;

import java.util.Comparator;

public class EventComparator implements Comparator<Model> {
    @Override
    public int compare(Model m1, Model m2) {
        
    	Event e1 = (Event) m1;
    	Event e2 = (Event) m2;
    	return e1.dtStart.compareTo(e2.dtStart);
    }
}