Ext.define('Gemster.view.Facebook', {
    extend  : 'Ext.List',
    xtype   : 'facebook',

    requires : [
        'Ext.plugin.PullRefresh'
    ],

    config  : {
        id : 'facebook',
        grouped         : false,
        emptyText       : 'empty',
        disableSelection: true,

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