class @InterviewScheduler.Collections.Interview extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('interviews')

    @schema: {
        user_id:
            label: 'Interviewer Id'
            type: String
        firstName:
            label: 'First Name'
            type: String
        lastName:
            label: 'Last Name'
            type: String
            optional: true
        email:
            type: String
            label: 'Email Address'
            regEx: SimpleSchema.RegEx.Email
        department_id:
            label: 'Department Id'
            type: String
        department:
            label: 'Department'
            type: String
        decided:
            type: Number
            label: 'Chosen Time'
            optional: true
        skype_id:
            type: String
            label: 'Skype Id'
            optional: true
        calendar_ids:
            type: [String]
            optional: true
        calendar_id:
            type: String
            optional: true
        event_id:
            type: String
            optional: true
        interviewers:
            type: [Object]
            optional: true
            blackbox: true
        interviewersForSearch:
            type: String
            optional: true
        status:
            type: String
            optional: true
        availableSlots:
            type: Number
            optional: true
    }

    @_collection.allow {
        insert: (userId, doc) ->
            doc.user_id is userId
    }

    updateStatus: (responses) ->
        status = 'accepted'

        for interviewer in @interviewers
            response = 'needsAction'

            if responses[interviewer.calendar_id]
                response = responses[interviewer.calendar_id]

            # refreshing status with whatever non accepted status
            if status is 'accepted' and response isnt status
                status = response

            interviewer.response = response

        # Enforcing declined if any of them is declined
        if _.find(@interviewers, (i) -> i.response is 'declined')
            status = 'declined'

        @update {
            interviewers: @interviewers
            status: status
            interviewersForSearch: _.map(@interviewers, (i) -> i.calendar_id).join(' ')
        }

