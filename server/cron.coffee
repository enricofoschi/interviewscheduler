# TODO move code to services layer

Meteor.startup ->
    SyncedCron.add {
        name: 'Check Events'
        schedule: (parser) ->
            return parser.text('every 1 hour')
        job: ->
            Crater.Services.InterviewScheduler.Interview.UpdateInterviewEvents()
    }

    Crater.Services.InterviewScheduler.Interview.UpdateInterviewEvents()

    SyncedCron.start()