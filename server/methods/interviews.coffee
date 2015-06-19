# TODO move code to services and trim methods controller style (as proxy between client / services)

Meteor.methods {
    'getNextAvailableTimeSlot': (interviewId) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.getNextAvailableTimeSlot interviewId

    'setInterview': (interviewId, start, skypeId) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.setInterview interviewId, start, skypeId

    'cancelInterview': (interviewId) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.cancelInterview interviewId

    'cancelInterviewEvent': (interviewId) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.cancelInterviewEvent interviewId

    'sendCandidateNewNotification': (interviewId) ->

        interviewService = Crater.Services.Get Services.INTERVIEWS
        interviewService.sendCandidateNewNotification interviewId
}