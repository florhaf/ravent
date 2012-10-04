package com.chaman.svc;

import org.restlet.Application;
import org.restlet.Restlet;
import org.restlet.routing.Router;

public class RaVentSvcApplication extends Application {
	
	@Override
	public synchronized Restlet createInboundRoot() {
	    
		Router router = new Router(getContext());
		
		router.attach("/events", 					Events.class);
		router.attach("/description", 				Descriptions.class);
		router.attach("/comments",					Comments.class);
		router.attach("/pictures",					Pictures.class);
		router.attach("/friends", 					Friends.class);
		router.attach("/attendings",				Attendings.class);
		router.attach("/followings",				Followings.class);
		router.attach("/users", 					Users.class);
		router.attach("/post", 						Posts.class);
		router.attach("/share",						Share.class);
		router.attach("/rsvp",						Rsvp.class);
		router.attach("/vote",						Votes.class);
		router.attach("/calendar",					Calendar.class);
		router.attach("/eventbackends",				EventBackends.class);
		router.attach("/eventstats", 				EventStats.class);
		router.attach("/sendEmail", 				SendEmail.class);
		router.attach("/visibility", 				GemsterVisibility.class);
		router.attach("/emp", 						EventMarketingPrograms.class);
		return router;
	}
}
