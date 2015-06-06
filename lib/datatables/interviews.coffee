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
        deleteCallback: (row) ->
            Helpers.Client.MeteorHelper.CallMethod 'cancelInterview', row, (e, r) ->
                if e
                    Helpers.Client.Notifications.Error 'We couldn\'t cancel the interview. Please cancel it manually!'
                else
                    Helpers.Client.Notifications.Success 'Interview cancelled!'

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

                    date = new Date data
                    date = new moment date

                    td.innerHTML = date.format('ddd Do MMM [at] HH:mm')
            }
            {
                data: "skype_id"
                title: "Skype"
            }
            {
                data: "interviewers"
                title: "Interviewers"
            }
        ]
    }
)

if Meteor.isClient
    $.fn.dataTable.ext.search.push (settings, data, dataIndex) ->
        console.log 'ok'
        return true