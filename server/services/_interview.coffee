class @Crater.Services.InterviewScheduler.Interview extends Crater.Services.InterviewScheduler.Base

    calendarApi = null
    eventApi = null
    authentication = null

    constructor: (_calendarApi, _eventApi) ->
        calendarApi = _calendarApi
        eventApi = _eventApi

    updateInterviewEvents: =>
        interviews = InterviewScheduler.Collections.Interview.where {
            status:
                $ne: 'accepted'
            event_id:
                $ne: null

        }

        for interview in interviews
            eventApi.getEvent interview.user_id, interview.calendar_id, interview.event_id, (e, r) ->
                responses = {}

                if r
                    for attendee in r.data.attendees
                        responses[attendee.email] = attendee.responseStatus


                interviewer_calendars = InterviewScheduler.Collections.Calendar.find({
                    calendar_id:
                        $in: Object.keys(responses)
                }, {
                    fields: {
                        _id: 1
                        calendar_id: 1
                    }
                }).fetch()

                interview.updateStatus(responses)

    getNextAvailableTimeSlot: (interviewId) ->
        interview = InterviewScheduler.Collections.Interview.first interviewId

        if not interview
            return

        now = new Date

        firstAvailability = InterviewScheduler.Collections.Availability.first {
            interview_id: interviewId
        }

        if firstAvailability and (now - firstAvailability.updatedAt) / 1000 / 60 < 5
            return

        InterviewScheduler.Collections.Availability.destroyAll {
            interview_id: interviewId
        }

        # Getting Interview and Calendars
        calendars = {}

        calendarsData = InterviewScheduler.Collections.Calendar.find({
            _id:
                $in: interview.calendar_ids
        }, {
            fields: {
                _id: 1
                calendar_id: 1
            }
        }).fetch()

        for calendar in calendarsData
            calendars[calendar.calendar_id] = calendar.id

        config = Helpers.Server.InterviewScheduler.Times.GetConfig()

        InterviewScheduler.Collections.TimeSlot.destroyAll {
            user_id: interview.user_id
        }

        # Updating Busy Schedule
        timeSlots = Meteor.wrapAsync(calendarApi.GetFreeBusy) interview.user_id, calendars, config
        for timeSlot in timeSlots
            InterviewScheduler.Collections.TimeSlot.create timeSlot

        # Getting time slot
        timesToCheck = Helpers.Server.Time.GetWorkingDaysTimeSlots config.startDate, config.daysToCheck, config.startHour, config.endHour, config.startMinute, config.endMinute, config.duration

        allTimes = []
        availableSlots = 0

        # Looping through time slots to find out who is available
        for timeToCheck in timesToCheck

            availability = {
                start: timeToCheck.start
                end: timeToCheck.end
                interview_id: interview.id
            }

            filters = {
                $and: [
                    {
                        user_id: interview.user_id
                    },
                    {
                        $and: [
                            {
                                start_int: {$lt: timeToCheck.end}
                            },
                            {
                                end_int: {$gt: timeToCheck.start}
                            }
                        ]
                    }
                ]
            }

            availableCals = InterviewScheduler.Collections.TimeSlot.find(filters, {
                fields: {
                    calendar_id: 1
                }
            }).fetch().map((x) -> x.calendar_id)

            busyCals = _.uniq availableCals, true

            availableCals = _.difference(calendars, busyCals)

            availability.calendar_ids = availableCals

            if availability.calendar_ids.length >= GlobalSettings.minimumInterviewersAvailable
                availableSlots++;

            InterviewScheduler.Collections.Availability.create availability

        interview.update {
            availableSlots: availableSlots
        }

        availableSlots

    setInterview: (interviewId, start, skypeId) ->
        interview = InterviewScheduler.Collections.Interview.first interviewId
        hrManager = MeteorUser.getUser interview.user_id

        interview.update {
            decided: start
            skype_id: skypeId
            status: 'needsAction'
        }

        availability = InterviewScheduler.Collections.Availability.first {
            start: start
            interview_id: interviewId
        }

        startDate = new Date availability.start * GlobalSettings.timeslotDivider
        endDate = new Date availability.end * GlobalSettings.timeslotDivider

        primaryCalendar = InterviewScheduler.Collections.Calendar.first {
            is_primary: true
            user_id: interview.user_id
        }

        attendees = InterviewScheduler.Collections.Calendar.find({
            _id: {
                $in: availability.calendar_ids
            }
        }, {
            fields: {
                calendar_id: 1
                _id: 1
            }
        }).fetch()

        attendees = _.map(_.sample(attendees, GlobalSettings.interviewers), (a) ->
            {
            _id: a.id
            calendar_id: a.calendar_id
            }
        )

        title = 'Interview with ' + interview.firstName + ' ' + (interview.lastName || '') + ' (skype: ' + interview.skype_id + ')'

        options = {
            params: {
                sendNotifications: true
            }
            data: {
                attendees: _.map(attendees, (c) -> {
                email: c.calendar_id
                responseStatus: 'needsAction'
                })
                start:
                    dateTime: startDate.toISOString()
                end:
                    dateTime: endDate.toISOString()
                reminder:
                    useDefault: false
                    overrides: [
                        {
                            method: 'email'
                            minutes: 15
                        }
                    ]
                description: title
                summary: title
            }
        }

        Meteor.wrapAsync(eventApi.createEvent) interview.user_id, primaryCalendar.calendar_id, options, (e, r) ->
            if e
                throw e
            else
                interview.update {
                    event_id: r.id
                    calendar_id: primaryCalendar.calendar_id
                    interviewers: attendees
                }

                Helpers.Server.InterviewScheduler.Email.Send {
                    template: 'time-choosen-hr-manager'
                    subject: interview.firstName + ' ' + interview.lastName + ' set a time for the interview'
                    data: {
                        firstName: hrManager.getFirstName()
                        url: Meteor.absoluteUrl 'admin/interview/all'
                        interviewers: _.map(attendees, (a) -> a.calendar_id)
                        time: (new moment(startDate)).format('ddd Do MMM [at] HH:mm')
                        skype: interview.skype_id
                        candidateFirstName: interview.firstName
                    }
                    to: hrManager.getEmail()
                    from: 'noreply@firstgra.de'
                }

    cancelInterview: (interview_id) ->
        interview = InterviewScheduler.Collections.Interview.first interview_id

        onCancel = =>
            interview.destroy()
            InterviewScheduler.Collections.Availability.destroyAll {
                interview_id: interview_id
            }

        if interview.event_id

            try
                Meteor.wrapAsync(eventApi.deleteEvent) interview.user_id, interview.calendar_id, interview.event_id
            catch error

        onCancel()

    cancelInterviewEvent: (interview_id) ->
        interview = InterviewScheduler.Collections.Interview.first interview_id

        interview.update {
            decided: null
            event_id: null
            status: null
            skype_id: null
        }

        try
            Meteor.wrapAsync(eventApi.deleteEvent) interview.user_id, interview.calendar_id, interview.event_id
        catch error

    sendCandidateNewNotification: (interview_id) ->
        interview = InterviewScheduler.Collections.Interview.first interview_id
        hrManager = MeteorUser.getUser(interview.user_id)

        Helpers.Server.InterviewScheduler.Email.Send {
            template: 'interview-candidate'
            subject: 'When Do You Want To Interview With ' + GlobalSettings.companyName + '?'
            data: {
                companyName: GlobalSettings.companyName
                firstName: interview.firstName
                url: Meteor.absoluteUrl 'interview/choose-time/' + interview.id
            }
            to: interview.email
            from: hrManager.getEmail()
        }

    updateCalendarsList: (callback) ->
        calendars = Meteor.wrapAsync(calendarApi.List)(Meteor.userId())

        userId = Meteor.userId()

        for calendar in calendars

            saved_calendar = InterviewScheduler.Collections.Calendar.first {
                calendar_id: calendar.id
                user_id: userId
            }

            if not saved_calendar
                InterviewScheduler.Collections.Calendar.create {
                    user_id: Meteor.userId()
                    calendar_id: calendar.id
                    name: calendar.summary
                    is_interviewer: false
                    is_room: false
                    is_primary: calendar.primary
                }
            else
                saved_calendar.update {
                    name: calendar.summary
                }


        calendars.length