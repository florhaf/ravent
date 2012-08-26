package com.chaman.util;

public class JSON {

	public static String GetValueFor(String key, String json) {
		
		String result = null;
		
		try {
			
			int keyIndex 	= json.indexOf(key + "\":");
			
			if (keyIndex != -1) {
				
				int startIndex	= keyIndex + key.length() + 2;
				int endIndex 	= json.indexOf("\"", startIndex + 1);

				if (endIndex == -1) {endIndex = json.indexOf(",", startIndex + 1);}
				if (endIndex == -1) {endIndex = json.indexOf("}", startIndex + 1);}
				
				result = json.substring(startIndex, endIndex);
				result = result.replace("\"", "");
				
				if (result.endsWith(",")) {
					
					result = result.substring(0, result.length() - 1);
				}
			}
		} catch (Exception ex) {
			
			// value or key not found
		}
		
		return result;
	}
	
	public static String RemoveSpaces(String dirty_string) {
		
		return dirty_string.replace(" ", "");
	}
	
	public static String GetCategories(String key, String json) {
		
		String result = "";
		int n = 0;
		
		while (json.indexOf(key) != -1) {
			
			if (n > 0) {
				
				result = result + "/";
			}
			
			int keyIndex 	= json.indexOf(key + "\":");
			
			int startIndex	= keyIndex + key.length() + 2;
			int endIndex 	= json.indexOf("\"", startIndex + 1);
			
			result = result + json.substring(startIndex, endIndex);
			
			json = json.substring(endIndex, endIndex + json.length() - endIndex);
			
			n++;
		}
		
		result = result.replace("\"", "");
		return result.toLowerCase();
	}
	
}


