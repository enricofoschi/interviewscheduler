((template) =>

    departmentId = new ReactiveVar null

    Helpers.Client.Application.addCallbacksToTemplate template.viewName, [
        'adaptive-label'
    ]

    template.rendered = ->
        departmentId.set $('.ddl-department').val()

    template.helpers {
        'departments': ->
            _.map InterviewScheduler.Collections.Department.all(), (d) ->
                {
                    value: d.id
                    label: d.name
                }

        'availableCalendars': ->
            id = departmentId.get()

            _.filter @calendars, (c) ->
                _.find c.department_ids || [], (d) ->
                    d is id
    }

    template.events {
        'change .ddl-department': (e) ->
            departmentId.set $(e.target).val()
    }

    Meteor.startup ->
        @AutoForm.hooks {
            insertInterviewForm: Helpers.Client.Form.GetFormHooks {
                before: (doc) ->
                    doc.user_id = Meteor.userId()

                    calendarIds = []

                    $('#insertInterviewForm .cb-calendar-enabled:checked').each ->

                        interviewer_id = $(@).attr('data-id')

                        calendarIds.push interviewer_id

                    if calendarIds.length < GlobalSettings.minimumInterviewersAvailable
                        Helpers.Client.Notifications.Error 'Uhm.... not enough interviewers.... no party! Please select at least ' + GlobalSettings.minimumInterviewersAvailable + ' interviewers'
                        return false

                    if doc.department_id
                        doc.department = (InterviewScheduler.Collections.Department.first doc.department_id).name

                    doc.calendar_ids = calendarIds

                    doc
            beginSubmit: ->
                Helpers.Client.Loader.Show()
            onSuccess: (type, id) ->
                    Helpers.Client.MeteorHelper.CallMethod 'getNextAvailableTimeSlot', id, (e, result) ->
                        if e
                            Helpers.Client.Notifications.Error e
                        else
                            if result >= GlobalSettings.minimumAvailabilities
                                Helpers.Client.MeteorHelper.CallMethod 'sendCandidateNewNotification', id, (e, r) ->
                                    if e
                                        Helpers.Client.Notifications.Error e
                                    else
                                        Helpers.Client.Notifications.Success 'Yay! We just contacted the candidate. Here you can see what they choose.... in REAL TIME!'
                                        Router.go '/admin/interview/' + id
                            else
                                Helpers.Client.Notifications.Error 'Damn! There aren\'t enough available slots with the interviewers selected (only ' + result + ' available)'
            }
        }

)(Helpers.Client.TemplatesHelper.Handle('admin.interview.new'))