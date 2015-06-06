Meteor.publish 'interviews', (interviewId) ->

    if Roles.userIsInRole @userId, ['hr']
        InterviewScheduler.Collections.Interview.find()
    else
        InterviewScheduler.Collections.Interview.find {
            _id: interviewId
        }