class @InterviewScheduler.Collections.Department extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('departments')

    @schema: {
        name:
            type: String
    }