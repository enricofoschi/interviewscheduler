@Services = _.extend @Services, {
    INTERVIEWS:
        key: 'interviews'
        service: ->
            authentication = {
                clientId: Meteor.settings.google.clientId
                secret: Meteor.settings.google.secret
            }
            calendarApi = new Crater.Api.Google.Calendar(authentication)
            eventApi = new Crater.Api.Google.Event(authentication)

            return new Crater.Services.InterviewScheduler.Interview calendarApi, eventApi
}

@Crater.Services.InitAll()