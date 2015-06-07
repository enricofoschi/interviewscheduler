class @Helpers.Server.InterviewScheduler.Email
    @Send: (options) ->

        head = Assets.getText 'templates/email/base/head.html'
        foot = Assets.getText 'templates/email/base/foot.html'

        Helpers.Server.Email.SetTemplates(head, foot)

        html = Assets.getText('templates/email/' + options.template + '.html')

        Helpers.Server.Email.Send _.extend(options, {
            html: html
        })