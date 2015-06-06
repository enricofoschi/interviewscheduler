class @InterviewScheduler.Collections.Calendar extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('calendars')

    @schema: {
        user_id:
            type: String
        calendar_id:
            type: String
        name:
            type: String
        is_interviewer:
            type: Boolean
        is_room:
            type: Boolean
        department_ids:
            type: [String]
            optional: true
        is_primary:
            type: Boolean
            optional: true
    }

    @_collection.allow {
        update: (userId, doc) ->
            doc.user_id is userId
    }

