class @Helpers.Server.InterviewScheduler.Times

    @GetConfig: =>

        startDate = new Date()
        startDate.setHours(0,0,0,0);
        startDate.setDate(startDate.getDate() + 2)

        startDate = @GetNextWorkingDay startDate, 0
        daysToCheck = Meteor.settings.interviewScheduler.timeSpan
        endDate = @GetNextWorkingDay new Date(startDate), daysToCheck

        {
            startDate: startDate
            endDate: endDate
            daysToCheck: daysToCheck
            startHour: Meteor.settings.interviewScheduler.startHour
            startMinute: Meteor.settings.interviewScheduler.startMinute
            endHour: Meteor.settings.interviewScheduler.endHour
            endMinute: Meteor.settings.interviewScheduler.endMinute
            duration: Meteor.settings.interviewScheduler.duration
        }

    @GetNextWorkingDay: (date, interval) =>

        while (isHoliday = @IsHoliday(date)) or interval > 0

            date.setDate(date.getDate() + 1)
            dayOfWeek = date.getDate()

            if not isHoliday
                interval--
        date

    @IsHoliday: (date) =>

        dayOfWeek = date.getDay()

        dayOfWeek is 6 or dayOfWeek is 0 or (Meteor.settings.holidays and _.find(Meteor.settings.holidays, (i) -> i is date.getDate()+'/' + (date.getMonth() + 1)))