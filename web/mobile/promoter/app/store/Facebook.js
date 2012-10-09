Ext.define('Gemster.store.Facebook', {
    extend: 'Ext.data.Store',

    config: {
        autoLoad    : false,
        proxy       : {
            model       : 'Gemster.model.Event',
            type        : 'ajax',
            reader      : {
                rootProperty    : 'records'
            },
            listeners   : {
                exception       : function(proxy, response) {

                    if (response.status == 200) {

                        var oResponse = Ext.decode(response.responseText);

                        Ext.Msg.alert('Server error', oResponse.message, Ext.emptyFn());
                    } else {

                        Ext.Msg.alert('Server error', response.status + ' ' + response.statusText, Ext.emptyFn());
                    }
                }
            }

        }
    }
});
