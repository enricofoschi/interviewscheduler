# TODO move code to services and trim methods controller style (as proxy between client / services)

Meteor.methods {
    'updateCalendarsList': (callback) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.updateCalendarsList callback
}