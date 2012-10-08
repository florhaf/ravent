Ext.Loader.setConfig({
    enabled: true,
    disableCaching : false
});

Ext.Loader.setPath('Ext', 'lib/touch2/src');

Ext.application({
    name                : 'Gemster',

    viewport: {
        autoMaximize: true
    },

    requires            : [
        'Ext.tab.Panel',
        'Ext.form.Panel'
    ],

    views               : [
        'Help',
        'Facebook',
        'ContactForm'
    ],

    models              : [
        'Event',
        'Contact'
    ],

    stores              : [
        'Facebook'
    ],

    controllers         : [
        'Facebook',
       'ContactForm'
    ],

    launch: function() {

        Ext.Viewport.add({
            xtype   : 'tabpanel',
            tabBar : {
                layout : {
                    pack : 'center',
                    align : 'center'
                },
                docked : Ext.browser.is.WebView ? 'bottom' : 'bottom'
            },
            //fullscreen: true,
            items : [{
                title : 'Help',
                xtype : 'help'
            },{
                title : 'Facebook',
                xtype : 'facebook'
            },{
                title : 'Gemster',
                flex : 1,
                html : 'home'
            },{
                title : 'Contact',
                xtype : 'contact-form'
            }]
        });
    }
});
