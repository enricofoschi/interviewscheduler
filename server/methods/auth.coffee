Meteor.methods {
    'onSignup': ->
        user = new MeteorUser Meteor.user()

        if user.getEmail().toLowerCase().indexOf(GlobalSettings.hrEmails) > -1
            Roles.addUsersToRoles Meteor.userId(), ['hr']
}