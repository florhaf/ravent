Ext.Loader.setConfig({
    enabled: true,
    disableCaching : false
});

Ext.Loader.setPath('Ext', 'lib/touch2/src');

Ext.application({
    name                : 'Gemster',

    requires            : [
        'Ext.form.Panel'
    ],

    views               : [
        'ContactForm'
    ],

    models              : [
        'Contact'
    ],

    stores              : [
    ],

    controllers         : [
       'ContactForm'
    ],

    launch: function() {

        Ext.Viewport.add({
            xtype   : 'contact-form'
        });
    }
});
