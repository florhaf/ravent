Ext.define('Gemster.view.Facebook', {
    extend  : 'Ext.List',
    xtype   : 'facebook',

    requires : [
        'Ext.plugin.PullRefresh'
    ],

    config  : {
        grouped         : false,
        emptyText       : 'empty',
        disableSelection: true,
        items : [{
            xtype : 'toolbar',
            docked : 'top',
            title : 'Facebook Events',
            items : [{
                xtype : 'spacer'
            },{
                xtype : 'button',
                text : 'logout'
            }]
        }],
        plugins: [{
            xclass      : 'Ext.plugin.PullRefresh',
            refreshFn   : function() {

                this.getParent().fireEvent('reload', this.up());
            }
        }],
        listeners : {
            painted : function() {

                this.fireEvent('facebook_customShow', this);
            }
        },
        itemTpl         : '{name}'
    }
});