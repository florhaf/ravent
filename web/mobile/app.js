Ext.Loader.setConfig({
    enabled: true,
    disableCaching : true
});

Ext.Loader.setPath('Ext', 'lib/touch2/src');

Ext.application({
    name                : 'Gemster',

    viewport: {
        autoMaximize: false
    },
    launch: function() {


        Ext.Viewport.add({
            scrollable: true,
            items : [{
                xtype : 'toolbar',
                docked : 'top',
                title : 'Gemster'
            }],

            layout : {

                type : 'vbox',
                pack: 'center',
                align: 'middle'
            },


            items : [{
                html : '<div class="header"><div class="header-text">Gemster</div></div>',
                width: '100%',
                docked: 'top'
            },{
                html : '<div style="margin-top: -20px; margin-bottom: 20px; color: #a9a9a9;"><b>The Entertainment Provider</b></div>'
            },{
                html : '<br />'
            },{

                xtype : 'button',
                ui : 'action',
                text : (Ext.os.is.ios) ? 'Get the app' : 'Gemster is only available for iOS, for now...',
                disabled : !(Ext.os.is.ios),
                width : '90%',
                listeners : {
                    tap : function() {

                        window.location = 'itms-services://?action=download-manifest&url=http://beta.gemsterapp.com/Gemster.plist';
                    }
                }
//                html : (Ext.os.is.ios) ?
//                    '<a href="itms-services://?action=download-manifest&url=http://beta.gemsterapp.com/Gemster.plist">Get the app</a>' :
//                    '<div style="color: #a9a9a9; text-align: center; width: 100%;">Gemster is only available on iOS, for now...</div>'
            },{
                html : '<br />'
            },{

                xtype : 'button',
                ui : 'confirm',
                text: 'Promoters',
                width : '90%',
                listeners : {
                    tap : function() {
                        window.location = "promoter/";
                    }
                }
            },{
                html : '<br />'
            },{
                html : '<a href="http://gemsterapp.com/?fullversion=true">Full Version</a>'
            }]

        });
    }
});
