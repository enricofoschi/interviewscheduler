Meteor.publish 'calendars', ->

    InterviewScheduler.Collections.Calendar.find {
        user_id: @userId
    }