((template) =>

    template.events {

        'click .btn-login-google' : (e, t) ->
            Meteor.loginWithGoogle {
                requestPermissions: [
                    'email',
                    'https://www.googleapis.com/auth/calendar'
                ]
                requestOfflineToken: true
            }
    }

)(Helpers.Client.TemplatesHelper.Handle('interviewAvailability'))