((template) =>

    editTimezone = new ReactiveVar false
    refresher = new ReactiveVar 0

    template.onCustomCreated = ->
        editTimezone.set false

    template.rendered = ->
        $('.ddl-timezones').select2();

    template.helpers {
        'timezone': ->
            refresher.get() # needed to ensure we can trigger a refresh manually
            date = moment()
            date.format('Z')

        'timezones': ->
            moment.tz.names()

        'editTimezone': ->
            editTimezone.get()

        'refresher': ->
            refresher.get()
    }

    template.events {
        'click .btn-change-timezone': ->
            editTimezone.set(not editTimezone.get())
        'change .ddl-timezones': (e) ->
            editTimezone.set false
            newTimezone = $(e.target).val()
            moment.tz.setDefault newTimezone
            refresher.set(refresher.get() + 1)
    }

)(Helpers.Client.TemplatesHelper.Handle('presentation.interview.choose-time'))