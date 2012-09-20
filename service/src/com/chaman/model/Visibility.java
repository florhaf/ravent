package com.chaman.model;

import java.util.ArrayList;

public class Visibility {

	int event_list_size;
	int NbVote;
	
	public Visibility () {
		
		super();
	}
	
	public Visibility (String uid, String accessToken, String latitude, String longitude, int max_post, int min_score) {
		
		ArrayList<Model> list = Event.Get(accessToken, latitude, longitude, latitude, longitude, "-420", 360, 6, 0, "en_US");
		
		this.NbVote  = 0;		
		this.event_list_size = 0;
		
		if (list != null && list.size() > 0) {
			
			this.event_list_size = list.size();
			
			for (int i = 0; i < list.size(); i++) {
				try {
				
					Event event = (Event) list.get(i);
					
					if (event.score < min_score) {
						
						continue;
					} else {
						
						if (this.NbVote > max_post) {
							
							break; // enough posting done in that location
						} else {
							
							Vote v = new Vote(accessToken, uid, String.valueOf(event.eid), "1", true);
							if (v.nb_vote == 1) {
								this.NbVote++;
							}
						}
					}
				} catch (Exception ex) {continue;}
			}
		}
	}

	public int getEvent_list_size() {
		return event_list_size;
	}

	public void setEvent_list_size(int event_list_size) {
		this.event_list_size = event_list_size;
	}

	public int getNbVote() {
		return NbVote;
	}

	public void setNbVote(int nbVote) {
		NbVote = nbVote;
	}
	
}
	
