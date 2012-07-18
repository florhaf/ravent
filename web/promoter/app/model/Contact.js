Ext.define('Gemster.model.Contact', {
	extend : 'Ext.data.Model',
	
	config : {
	    fields: [{
	    	name : 'uid',
	    	type : 'string'
	    },{
	    	name : 'email',
	    	type : 'string'
	    },{
	    	name : 'phone',
	    	type : 'string'
	    },{
	    	name : 'purpose',
	    	type : 'string'
	    }]
	}
});