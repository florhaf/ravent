Ext.Loader.setConfig({
    enabled: true,
    disableCaching : true
});

Ext.Loader.setPath('Ext', 'lib/touch2/src');

Ext.application({
    name                : 'Gemster',


    launch: function() {

        Ext.Viewport.add({

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

            html : (Ext.os.is.ios) ?
                '<a href="itms-services://?action=download-manifest&url=http://ravent.globalviaduct.com/Gemster.plist">Download Gemster beta</a>' :
                '<div style="color: #a9a9a9; text-align: center; width: 100%;">You must access this web site with mobile safari to download Gemster</div>'

        });
    }
});
