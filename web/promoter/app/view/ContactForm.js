Ext.define('Gemster.view.ContactForm', {
    extend:'Ext.form.Panel',
    xtype:'contact-form',

    requires:[
        'Ext.form.FieldSet',
        'Ext.field.Select',
        'Ext.field.Email'
    ],

    config : {
        id:'contact-form',
        scrollable:'vertical',
        items : [{
            xtype : 'fieldset',
            title : 'I want to',
            instructions : 'Contact us about your event, we will get back to you.',
            items : [{
                xtype : 'selectfield',
                id : 'purpose',
                options : [{
                    text : 'promote my event',
                    value : 'promote my event'
                },{
                    text : 'offer specials',
                    value : 'offer specials'
                },{
                    text : 'sell tickets',
                    value : 'sell tickets'
                }]
            },{
                xtype : 'emailfield',
                id : 'email',
                label : 'Email'
            },{
                xtype : 'textfield',
                id : 'phone',
                label : 'Phone',
                listeners : {
                    painted : function(textfield) {

                        var input = textfield.element.down('input');
                        input.set({
                            pattern : '[0-9]*'
                        });

                    }
                }
            }]
        },{
            xtype : 'button',
            text : 'Send',
            ui : 'confirm',
            listeners : {
                tap : function() {

                    Ext.getCmp('contact-form').fireEvent('send');
                }
            }
        },{
            html : '<div style="font-size: 16px; color: #a9a9a9;"><p><b>Promote my event</b></p>Always be on top! your event will appear on top of the list of as lon as 1 week before the actual start date, and thus will be the one viewed by all our users.</div>'
        },{
            html : '<div style="font-size: 16px; color: #a9a9a9;"><p><b>Offer specials</b></p>Enhance the experience! add goodies to your event only for our app users and gain more popularity.</div>'
        },{
            html : '<div style="font-size: 16px; color: #a9a9a9;"><p><b>Sell tickets</b></p>Get organized! add direct link to your ticket provider for an easy access from your event detail page on Gemster.</div>'
        }]
    }
});