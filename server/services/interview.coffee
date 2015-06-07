class @Crater.Services.InterviewScheduler.Interview extends Crater.Services.InterviewScheduler.Base

    @UpdateInterviewEvents: =>
        interviews = InterviewScheduler.Collections.Interview.where {
            status:
                $ne: 'accepted'
            event_id:
                $ne: null

        }

        for interview in interviews
            Crater.Api.Google.Calendar.GetEvent interview.user_id, interview.calendar_id, interview.event_id, (e, r) ->
                responses = {}

                if r
                    for attendee in r.data.attendees
                        responses[attendee.email] = attendee.responseStatus


                interviewer_calendars = InterviewScheduler.Collections.Calendar.find({
                    calendar_id:
                        $in: Object.keys(responses)
                }, {
                    fields: {
                        _id: 1
                        calendar_id: 1
                    }
                }).fetch()

                interview.updateStatus(responses)