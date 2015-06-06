Meteor.methods {
    'onSignup': ->
        user = new MeteorUser Meteor.user()

        if user.getEmail().indexOf('@rocket-internet.de') > -1
            console.log 'Here'
            Roles.addUsersToRoles Meteor.userId(), ['hr']
}