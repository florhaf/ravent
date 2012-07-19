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
	    }],
        validations: [
            {type: 'format',   name: 'email', matcher: /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/, message:"Wrong Email Format"},
            {type : 'presence', name:'phone', message:"Enter a valid phone number"}
         ]

    }
});