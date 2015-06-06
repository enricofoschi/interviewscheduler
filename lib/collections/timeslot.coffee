class @InterviewScheduler.Collections.TimeSlot extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('timeslots')

    @schema: {
        start_int:
            type: Number
        end_int:
            type: Number
        user_id:
            type: String
        calendar_id:
            type: String
    }

Meteor.startup( ->

    if Meteor.isServer
        InterviewScheduler.Collections.TimeSlot._collection._ensureIndex {
            start_int: 1
        }
        InterviewScheduler.Collections.TimeSlot._collection._ensureIndex {
            end_int: 1
        }
)