package com.chaman.model;

import java.util.List;
import com.restfb.Facebook;

/* Used to do multiple queries in one call using restfb */
public class MultiqueryResults {
	  @Facebook
	  List<Attending> invited_info;
	  @Facebook
	  List<Attending> invited_rsvp;
}
