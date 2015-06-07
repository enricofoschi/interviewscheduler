((template) =>

    template.events {

        'click .btn-login-google' : (e, t) ->
            Meteor.loginWithGoogle {
                requestPermissions: [
                    'email',
                    'https://www.googleapis.com/auth/calendar'
                ]
                requestOfflineToken: true
            }, (e, r) ->
                Helpers.Client.MeteorHelper.CallMethod 'onSignup', (e, r) ->
                    Router.go '/admin/hr/setup'
    }

)(Helpers.Client.TemplatesHelper.Handle('login'))