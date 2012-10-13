package com.chaman.model;

import java.util.ArrayList;

public class Visibility extends Model  {

	int event_list_size;
	int NbVote;
	
	public Visibility () {
		
		super();
	}
	
	public Visibility (String uid, String accessToken, String latitude, String longitude, int max_post, int min_score, int searchTimeFrame, boolean retry, String city) {
		
		try {
			
			ArrayList<Model> list = Event.Get(accessToken, latitude, longitude, latitude, longitude, "-420", searchTimeFrame, 15, 0, "en_US", "true");
			
			this.NbVote  = 0;		
			this.event_list_size = 0;
			
			if (list != null && list.size() > 0) {
				
				this.event_list_size = list.size();
				
				for (int i = this.event_list_size - 1; i >= 0; i--) {
					
					Event event = (Event) list.get(i);
					
					try {
						
						if (event.score < min_score) {
							
							continue;
						} else {
							
							if (this.NbVote > max_post) {
								
								break; // enough posting done in that location
							} else {
								
								Vote v = new Vote(accessToken, uid, String.valueOf(event.eid), "1", true, "Dropped a gem to up-vote this event");
								if (v.nb_vote == 1) {
				
									this.NbVote++;
									/*
									ConfigurationBuilder cb = new ConfigurationBuilder();
									cb.setDebugEnabled(true)
									.setOAuthConsumerKey("QsJQApEU7TUPZN9dQkgLw")
									.setOAuthConsumerSecret("31PhHAhpx54DHJiaDOCM0ARqLoEDJJXbxCyOVCQySUk")
									.setOAuthAccessToken("722756468-JMJp6Q2XLUjpNm8azl24Rw8Ep4J0v4CWTYALuOST")
									.setOAuthAccessTokenSecret("sN07PzN2KlxGIDgAvdN1jPcXArv7rNSf2VoqJ43AU");
									TwitterFactory tf = new TwitterFactory(cb.build());
									Twitter twitter = tf.getInstance();
								
									twitter.updateStatus( (event.filter.equals("Other") ? "New #Event" : "#" + event.filter) + (city != null ? " in #" + city.replaceAll("[^0-9A-Za-z]", "") : "") + " | " 
											+ event.name + " @" + event.location.replaceAll("[^0-9A-Za-z]", "") + " @Gemster_app"
											+ " | see more: http://gemsterapp.com/facebook/event_page.php?eid=" + event.eid);				*/	
								}
							}
						}
					} catch (Exception ex) {log.severe( event.eid + ": " + ex.toString()); continue;}
				}
			}
			
			if (this.NbVote < max_post && retry) {
				
				new Visibility(uid, accessToken, latitude,longitude, max_post, min_score, 168, false, city);
			}
			
		} catch (Exception ex) {
			log.severe("Visibility: " + ex.toString());
			new Visibility(uid, accessToken, latitude,longitude, max_post, min_score, 96, false, city);
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
	
