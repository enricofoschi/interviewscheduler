Meteor.methods {
    'onSignup': ->
        user = new MeteorUser Meteor.user()

        if user.getEmail().indexOf('@rocket-internet.de') > -1
            Roles.addUsersToRoles Meteor.userId(), ['hr']
}