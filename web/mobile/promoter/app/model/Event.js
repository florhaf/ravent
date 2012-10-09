Ext.define('Gemster.model.Event', {
    extend: 'Ext.data.Model',

    config: {
        fields: [
            'eid',
            'name',
            'latitude',
            'longitude',
            'location',
            'distance',
            'time_start',
            'time_end',
            'date_start',
            'date_end',
            'score',
            'picture',
            'group',
            'invited_by'
        ]
    }
});