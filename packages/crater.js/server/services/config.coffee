@Services = {
    LOG:
        key: 'log'
        service: -> new Crater.Services.Core.Log()

    LINKEDIN:
        key: 'linkedin',
        service: -> new Crater.Services.ThirdParties.LinkedIn()

}

Meteor.startup ->

    for own key, value of Services
        @Crater.Services.Init value