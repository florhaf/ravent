Ext.define('Gemster.controller.ContactForm', {
    extend	: 'Ext.app.Controller',

    config : {
        refs : {
            view : 'contact-form'
        },
        control : {
            view : {
                send : 'send'
            }
        }
    },

    init : function() {

    },

    send : function(options) {

        var model = Ext.create("Gemster.model.Contact");
        model.data.purpose = Ext.getCmp('purpose').getValue();
        model.data.email = Ext.getCmp('email').getValue();
        model.data.phone = Ext.getCmp('phone').getValue();

        var pageParameters = Ext.urlDecode(window.location.search.substring(1));
        model.data.uid = pageParameters['uid'];

        var errors = model.validate();
        var message = '';

        var config	= {
            method	: 'POST',
            url 	: 'php/submit.php?to=promoter@gemsterapp.com&ajax=1',
            withCredentials: true,
            useDefaultXhrHeader: false,
            params	: model.data,
            scope	: this,
            success	: this._onSubmitSuccess,
            failure : this._onSubmitFailure
        };

        if (errors.isValid()) {

            this.getView().setMasked({
                xtype: "loadmask",
                message: "Loading..."
            });

            Ext.Ajax.request(config);
        } else {

            Ext.each(errors.items, function(record, index){

                message += record.getMessage() + '<br>';
            });

            Ext.Msg.alert('Error', message, Ext.emptyFn);
        }
    },
    _onSubmitSuccess : function(response, opts) {

        this.getView().setMasked(false);

        Ext.Msg.alert("Thanks!", "We will get back to you as soon as possible.", Ext.emptyFn);

        Ext.getCmp('purpose').setValue('promote my event');
        Ext.getCmp('email').setValue('');
        Ext.getCmp('phone').setValue('');

    },
    _onSubmitFailure : function(response, opts) {

        this.getView().setMasked(false);

        Ext.Msg.alert("Woops!", "An error occured...<br />Try again.", Ext.emptyFn);
    },
    _readQueryString : function() {

        var result 	= [];

        var query	= window.location.search.substring(1);
        var params 	= query.split('&');

        for (var i = 0; i < params.length; i++) {

            var pos = params[i].indexOf('=');

            if (pos > 0) {

                var key = params[i].substring(0, pos);
                var val = params[i].substring(pos + 1);

                result[key] = val;
            }
        }

        return result;
    }
});