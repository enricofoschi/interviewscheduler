Meteor.startup ->
    ServiceConfiguration.configurations.remove {}
    ServiceConfiguration.configurations.insert {
        service: "google",
        clientId: Meteor.settings.google.clientId,
        secret: Meteor.settings.google.secret
    }