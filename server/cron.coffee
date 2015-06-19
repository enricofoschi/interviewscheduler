# TODO move code to services layer

Meteor.startup ->
    interviewService = Crater.Services.Get Services.INTERVIEWS

    SyncedCron.add {
        name: 'Check Events'
        schedule: (parser) ->
            return parser.text('every 1 hour')
        job: ->
            interviewService.updateInterviewEvents()
    }


    interviewService.updateInterviewEvents()

    SyncedCron.start()