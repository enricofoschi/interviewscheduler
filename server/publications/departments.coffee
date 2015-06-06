Meteor.publish 'departments', ->

    InterviewScheduler.Collections.Department.find()