package com.chaman.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class Geo {

	public static float Fence(float lat1, float lon1, float lat2, float lon2) {
		
		float result;
		
	    double earthRadius = 3958.75;
	    
	    double dLat = Math.toRadians(lat2 - lat1);
	    double dLon = Math.toRadians(lon2 - lon1);
	    
	    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
	               Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
	               Math.sin(dLon / 2) * Math.sin(dLon / 2);
	    
	    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	    
	    result = (float) (earthRadius * c);

	    return result;
	}
	
	public static float Fence(String lat1, String lon1, String lat2, String lon2) {
		
		return Geo.Fence(new Float(lat1), new Float(lon1), new Float(lat2), new Float(lon2));
	}
	
	public static String Code(String address) {
		
		String result = null;
		
		String GEOCODER_REQUEST_PREFIX_FOR_XML = "http://maps.google.com/maps/api/geocode/xml";
		
		HttpURLConnection conn = null;
		
		try {
			
			// prepare a URL to the geocoder
			URL url = new URL(GEOCODER_REQUEST_PREFIX_FOR_XML + "?address=" + URLEncoder.encode(address, "UTF-8") + "&sensor=false");
			
			// prepare an HTTP connection to the geocoder
		    conn = (HttpURLConnection) url.openConnection();
		    
		    Document geocoderResultDocument = null;
		    
		    // open the connection and get results as InputSource.
		    conn.connect();
	    	InputSource geocoderResultInputSource = new InputSource(conn.getInputStream());
	    	
	    	// read result and parse into XML Document
	        geocoderResultDocument = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(geocoderResultInputSource);
	        
	        // prepare XPath
	        XPath xpath = XPathFactory.newInstance().newXPath();

	        // extract the result
	        NodeList resultNodeList = null;
	        
	        resultNodeList = (NodeList) xpath.evaluate("/GeocodeResponse/result/geometry/location/*", geocoderResultDocument, XPathConstants.NODESET);
	        
	        float lat = 0;
	        float lng = 0;
	        
	        for(int i=0; i<resultNodeList.getLength(); ++i) {
	        	
	        	Node node = resultNodeList.item(i);
	        	
	        	if("lat".equals(node.getNodeName())) {
	        		
	        		lat = Float.parseFloat(node.getTextContent());
	        	}
	        	
	        	if("lng".equals(node.getNodeName())) {
	        		
	        		lng = Float.parseFloat(node.getTextContent());
	        	}
	        	
	        	result = lat + "/" + lng;
	        }
			
		} catch (MalformedURLException e) {
			
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			
			e.printStackTrace();
		} catch (IOException e) {
			
			e.printStackTrace();
		} catch (SAXException e) {
			
			e.printStackTrace();
		} catch (ParserConfigurationException e) {
			
			e.printStackTrace();
		} catch (XPathExpressionException e) {
			
			e.printStackTrace();
		} finally {
		      conn.disconnect();
	    }
		
		return result;
	}
	
}
