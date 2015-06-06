# TODO move code to services and trim methods controller style (as proxy between client / services)

Meteor.methods {
    'updateCalendarsList': (callback) ->
        @unblock()

        calendars = Meteor.wrapAsync(Crater.Api.Google.Calendar.List)(Meteor.userId())

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
                    is_primary: calendar.primary
                }


        calendars.length

    'getNextAvailableTimeSlot': (interviewId) ->
        @unblock()

        interview = InterviewScheduler.Collections.Interview.first interviewId

        now = new Date

        firstAvailability = InterviewScheduler.Collections.Availability.first {
            interview_id: interviewId
        }

        if firstAvailability and (now - interview.updatedAt) / 1000 / 60 < 30
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
        Meteor.wrapAsync(Crater.Api.Google.Calendar.GetFreeBusy) interview.user_id, calendars, config, (e, timeSlots) ->
            for timeSlot in timeSlots
                InterviewScheduler.Collections.TimeSlot.create timeSlot

            # Getting time slot
            timesToCheck = Helpers.Server.Time.GetWorkingDaysTimeSlots config.startDate, config.daysToCheck, config.startHour, config.endHour, config.startMinute, config.endMinute, config.duration

            allTimes = []

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

                InterviewScheduler.Collections.Availability.create availability

    'setInterview': (interviewId, start, skypeId) ->

        @unblock()

        interview = InterviewScheduler.Collections.Interview.first interviewId

        interview.update {
            decided: start
            skype_id: skypeId
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

        attendees = _.map(_.sample attendees, GlobalSettings.interviewers, (a) -> {
            _id: a.id
            calendar_id: a.calendar_id
        })

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

        Meteor.wrapAsync(Crater.Api.Google.Calendar.CreateEvent) interview.user_id, primaryCalendar.calendar_id, options, (e, r) ->
            if e
                throw e
            else
                interview.update {
                    event_id: r.id
                    calendar_id: primaryCalendar.calendar_id
                    interviewers: attendees
                }

    'cancelInterview': (interview_id) ->
        interview = InterviewScheduler.Collections.Interview.first interview_id

        if interview.user_id is Meteor.userId()

            onCancel = =>
                interview.destroy()
                InterviewScheduler.Collections.Availability.destroyAll {
                    interview_id: interview_id
                }

            if interview.event_id

                Meteor.wrapAsync(Crater.Api.Google.Calendar.DeleteEvent) interview.user_id, interview.calendar_id, interview.event_id, (e, r) ->
                    if e
                        console.log e

            onCancel()
}