# TODO move code to services and trim methods controller style (as proxy between client / services)

Meteor.methods {
    'updateCalendarsList': (callback) ->
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
                }


        calendars.length
}