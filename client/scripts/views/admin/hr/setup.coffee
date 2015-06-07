((template) =>

    calendars = new ReactiveVar null

    template.onCustomCreated = ->
        Helpers.Client.MeteorHelper.CallMethod 'updateCalendarsList', (e, r) ->
            if e or not r
                Helpers.Client.Notifications.Error 'Damn! Something went wrong and we couldn\'t get your list of calendars'
                calendars.set false

    template.helpers {
        calendars: ->
            InterviewScheduler.Collections.Calendar.find({}, {
                sort: {
                    name: 1
                }
            }).fetch()
        notFound: ->
            calendars.get() is false
        departments: ->
            template.currentInstance.data.departments
        hasDepartment: (calendar) ->
            _.find calendar.department_ids, (c) => c is @id
    }

    template.events {
        'click .btn-type': (e) ->
            $target = $(e.target)

            clicked = $target.hasClass 'btn-primary'

            $target.siblings('.btn-type').removeClass('btn-primary')

            updateObj = {}
            updateObj.is_interviewer = false
            updateObj.is_room = false

            if not clicked
                $target.addClass 'btn-primary'

                updateObj[$target.attr('data-key')] = true

            @update updateObj

        'click .btn-set-primary': (e) ->
            # Disabling current primary calendar
            primaryCalendar = InterviewScheduler.Collections.Calendar.first {
                user_id: Meteor.userId()
                is_primary: true
            }

            if primaryCalendar
                primaryCalendar.update {
                    is_primary: false
                }

            # Setting current as primary
            @update {
                is_primary: true
            }

        'click .btn-department': (e) ->

            $target = $(e.target)

            clicked = $target.hasClass 'btn-success'

            departmentId = $target.attr 'data-value'

            calendar = InterviewScheduler.Collections.Calendar.first $target.parents('.calendar:first').attr('data-id')

            if clicked
                calendar.pull 'department_ids', departmentId
                $target.removeClass 'btn-success'
            else
                calendar.push {
                    'department_ids': [departmentId]
                }
                $target.addClass 'btn-success'
    }

)(Helpers.Client.TemplatesHelper.Handle('admin.hr.setup'))