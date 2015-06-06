((template) =>

    calendars = {}

    isInterviewer = ->
        template.currentInstance.data.interview.user_id is Meteor.userId() and Meteor.userId()

    template.onCustomCreated = ->

        # Calendars
        calendarsData = InterviewScheduler.Collections.Calendar.all()

        for calendar in calendarsData
            calendars[calendar.id] = calendar.name

        # Resetting availability
        Helpers.Client.MeteorHelper.CallMethod 'getNextAvailableTimeSlot', template.currentInstance.data.interviewId

    template.events {
        'click .time-slot.selectable': (e) ->

            e.preventDefault()

            if isInterviewer() #or template.currentInstance.data.interview.decided
                return

            start_int = @start
            start = new Date(start_int * GlobalSettings.timeslotDivider)
            start = new moment(start)

            # Refactor using promises
            Helpers.Client.Notifications.Confirm 'Do you want to start the interview at ' + start.format('HH:mm') + '?', =>

                Helpers.Client.Notifications.Prompt 'The interview is going to be on Skype. What is your Skype ID?', (skypeId) ->

                    Helpers.Client.MeteorHelper.CallMethod 'setInterview',template.currentInstance.data.interviewId, start_int, skypeId, (e, r) =>

                        if isInterviewer()
                            interviewers = r.interviewers.join(', ')

                            Helpers.Client.Notifications.Success 'Great. An Invitation has been sent to ' + interviewers
                            + '. <strong>Remember to send the invitation to the candidate through JobVite</strong>'
                        else
                            msg = 'Awesome. You will soon receive an invitation. Make sure you '\
                            + 'Don\'t take any other appointments for ' + start.format('ddd Do MMM') + ' at ' + start.format('HH:mm')  + '.'

                            Helpers.Client.Notifications.Success msg
    }

    template.helpers {

        'daysMatrix': ->

            days = _.groupBy @availabilities, (element, index) ->
                    date = new Date element.start * GlobalSettings.timeslotDivider
                    date.setHours 0, 0, 0, 0
                    date.getTime() / GlobalSettings.timeslotDivider

            retVal = []

            for own key,value of days
                retVal.push {
                    day: key
                    availabilities: _.sortBy value, (v) -> v.start
                }

            retVal = _.sortBy retVal, (r) -> r.day

            retVal.toMatrix 6

        'getDay': (timestamp) ->
            day = new Date timestamp * GlobalSettings.timeslotDivider

            day = new moment(day)
            day.format('ddd Do MMM')

        'getSlot': (slot) ->
            start = new Date slot.start * GlobalSettings.timeslotDivider
            end = new Date slot.end * GlobalSettings.timeslotDivider

            start = new moment(start)
            end = new moment(end)

            start.format('HH:mm') + ' - ' + end.format('HH:mm')

        'getCalendars': (slot) ->

            if slot.calendar_ids.length < GlobalSettings.minimumAvailability
                return ''

            ret = ''

            for calendar_id in slot.calendar_ids when calendars[calendar_id]
                if ret
                    ret += '\n'

                ret += calendars[calendar_id]

            ret

        'isSelectable': ->
            @calendar_ids.length >= GlobalSettings.minimumAvailability

        'decided': ->
            if not @interview.decided
                return false

            date = new Date @interview.decided * GlobalSettings.timeslotDivider
            date = new moment date
            date.format('ddd Do MMM') + ' at ' + date.format('HH:mm')

        'refresh': (calendars) ->
            window.setTimeout ->
                $('[data-toggle="tooltip"]').tooltip()
            , 10
            return ''
    }

)(Helpers.Client.TemplatesHelper.Handle('interviewAvailability'))