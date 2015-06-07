Meteor.startup( ->
    TabularTables.Create 'Interviews', {
        name: "InterviewsList"
        collection: InterviewScheduler.Collections.Interview._collection,
        prefix: '/admin/interview/'
        pageLength: 5000
        dom: '<f<t>i>'
        deletable: true
        viewable: true
        deleteText: 'Cancel'
        extraFields: ['status']
        deleteCallback: (row) ->
            Helpers.Client.MeteorHelper.CallMethod 'cancelInterview', row, (e, r) ->
                if e
                    Helpers.Client.Notifications.Error 'We couldn\'t cancel the interview. Please cancel it manually!'
                else
                    Helpers.Client.Notifications.Success 'Interview cancelled!'

        createdRow: (row, data) ->
            switch data.status
                when 'declined'
                    $(row).addClass('danger')
                when 'accepted'
                    $(row).addClass('success')
                else
                    $(row).addClass('warning')

        columns: [
            {
                data: "firstName"
                title: "First Name"
            }
            {
                data: "lastName"
                title: "Last Name"
            }
            {
                data: "email"
                title: "Email"
            }
            {
                data: "department"
                title: "Department"
            }
            {
                data: "decided"
                title: "When"
                createdCell: (td, data, row) ->

                    if not data
                        td.innerHTML = ''
                        return

                    date = new Date data * GlobalSettings.timeslotDivider
                    date = new moment date

                    td.innerHTML = date.format('ddd Do MMM [at] HH:mm')
            }
            {
                data: "skype_id"
                title: "Skype"
            }
            {
                data: 'interviewersForSearch'
                title: "Only For Search"
                visible: false
            }
            {
                data: "interviewers"
                title: "Interviewers"
                createdCell: (td, data) ->

                    if not data
                        td.innerHTML = ''
                        return

                    content = ''

                    interviewersByStatus = _.groupBy(data, (interviewer) -> interviewer.response)

                    for own key, value of interviewersByStatus

                        label = key
                        if key is 'needsAction' or not key
                            label = 'Must RSVP'

                        content += '<strong class="block">' + label + ': </strong><ul class="list-unstyled">'

                        for interviewer in value
                            content += '<li>' + interviewer.calendar_id.toString().htmlEncode() + '</li>'

                        content += '</ul>'

                    td.innerHTML = content
            }
        ]
    }
)