class @InterviewScheduler.Collections.Availability extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('availability')

    @schema: {
        start:
            type: Number
        end:
            type: Number
        interview_id:
            type: String
        calendar_ids:
            type: [String]
    }