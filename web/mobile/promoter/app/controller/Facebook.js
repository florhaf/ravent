Ext.define('Gemster.controller.Facebook', {
    extend: 'Ext.app.Controller',

    requires : [
    ],

    config : {
        refs    : {
            view    : 'facebook'
        },
        control : {
            view    : {
                itemtap     : 'onItemTap',
                reload      : 'load',
                events_list_customShow  : 'facebook_customShow'
            }
        }
    },

    events_list_customShow : function(view) {

        if (view.getStore() == null) {

            this.loadStore();
        }
    },

    loadStore   : function(options) {

        var view = this.crtView;

        if (view.getStore() == null) {

            view.setStore(Ext.create('Gemster.store.Facebook'));
        }

        var lat = 40.743538;
        var lon = -73.972508;
        var tz = -d.getTimezoneOffset();
        var local = 'en_US';

        view.getStore().load({
            url : '../php/proxy.php?proxy_url=' +
                encodeURIComponent('http://api.gemsterapp.com/events?userID=' + userId +
                    '&longitude=' + lon +
                    '&latitude=' + lat +
                    '&access_token=' + access_token +
                    '&timezone_offset=' + tz +
                    '&locale=' + local + '&promoter=true')
        });
    },

    onItemTap     : function(list, index, node, record) {

        this.getApplication().fireEvent(Config.currentTab + '_push_view', {
            xtype   : 'Ravent.view.events.Details',
            data    : record.data
        });
    }
});