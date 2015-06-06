Meteor.publish 'availabilities', (interviewId) ->

    InterviewScheduler.Collections.Availability.find {
        interview_id: interviewId
    }