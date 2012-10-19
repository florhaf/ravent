Ext.define('Gemster.controller.Facebook', {
    extend: 'Ext.app.Controller',

    requires: ['Ext.MessageBox'],

    config : {
        refs    : {
            view    : 'facebook'
        },
        control : {
            view    : {
                itemtap     : 'onItemTap',
                reload      : 'loadStore',
                facebook_customShow  : 'facebook_customShow'
            }
        }
    },

    _appId : '',

    init : function() {

        window.fbAsyncInit = Ext.bind(this.onFacebookInit, this);

        (function(d){
            var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
            js = d.createElement('script'); js.id = id; js.async = true;
            js.src = "//connect.facebook.net/en_US/all.js";
            d.getElementsByTagName('head')[0].appendChild(js);
        }(document));
    },

    onFacebookInit: function() {

        var me = this;

        FB.init({
            appId  : JWF.app.facebookAppId,
            cookie : true
        });

        FB.Event.subscribe('auth.logout', Ext.bind(me.onLogout, me));

        FB.getLoginStatus(function(response) {

            clearTimeout(me.fbLoginTimeout);

            me.hasCheckedStatus = true;
            Ext.Viewport.setMasked(false);

            Ext.get('splashLoader').destroy();
            Ext.get('rwf-body').addCls('greyBg');

            if (response.status == 'connected') {
                me.onLogin();
            } else {
                me.login();
            }
        });

        me.fbLoginTimeout = setTimeout(function() {

            Ext.Viewport.setMasked(false);

            Ext.create('Ext.MessageBox', {
                title: 'Facebook Error',
                message: [
                    'Facebook Authentication is not responding. ',
                    'Please check your Facebook app is correctly configured, ',
                    'then check the network log for calls to Facebook for more information.',
                    'Restart the app to try again.'
                ].join('')
            }).show();

        }, 10000);
    },

    login: function() {
        Ext.Viewport.setMasked(false);
        var splash = Ext.getCmp('login');
        if (!splash) {
            Ext.Viewport.add({ xclass: 'JWF.view.Login', id: 'login' });
        }
        Ext.getCmp('login').showLoginText();
    },

    onLogin: function() {

        var me = this,
            errTitle;

        FB.api('/me', function(response) {

            if (response.error) {
                FB.logout();

                errTitle = "Facebook " + response.error.type + " error";
                Ext.Msg.alert(errTitle, response.error.message, function() {
                    me.login();
                });
            } else {
                JWF.userData = response;
                if (!me.main) {
                    me.main = Ext.create('JWF.view.Main', {
                        id: 'main'
                    });
                }
                Ext.Viewport.setActiveItem(me.main);
                Ext.getStore('Runs').load();
            }
        });
    },

    logout: function() {
        Ext.Viewport.setMasked({xtype: 'loadmask', message: 'Logging out...'});
        FB.logout();
    },

    /**
     * Called when the Logout button is tapped
     */
    onLogout: function() {

        if (!this.hasCheckedStatus) return;

        this.login();

        Ext.Viewport.setMasked(false);
        Ext.Viewport.setActiveItem(Ext.getCmp('login'));
        Ext.getStore('Runs').removeAll();

        this.logoutCmp.destroy();
    },

    facebook_customShow : function(view) {

        if (this.getView().getStore() == null) {

            this.loadStore();
        }
    },

    loadStore   : function(options) {

        if (this.getView().getStore() == null) {

            this.getView().setStore(Ext.create('Gemster.store.Facebook'));
        }

        var d = new Date();
        var userId = '698467887';
        var access_token = 'AAAEQNGOuZAOsBACKrkiiF0F7UACbxt4aPiPjZAOcJksDJsYh89k6y4iPZBak1uH5hdSZC7Xg1xMNeoCscY9vDMpdItX9BPuVVgix4XVEMuJkoXnhE8eb';
        var lat = 40.743538;
        var lon = -73.972508;
        var tz = -d.getTimezoneOffset();
        var local = 'en_US';

        this.getView().getStore().load({
            url : '../../php/proxy.php?proxy_url=' +
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