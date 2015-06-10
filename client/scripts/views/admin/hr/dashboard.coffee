((template) =>

    template.rendered = ->
        charts = $ '.pie-chart'

        charts.each ->
            $this = $ @
            ctx = @getContext("2d");
            data = EJSON.parse($this.attr('data-chart'))

            chart = new Chart(ctx).Doughnut data, {
                legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
            }

            legend = chart.generateLegend()

            $this.parents('.chart-container:first').find('.legend-container').html(legend)


    template.helpers {
        interviewsByDepartmentMatrix: ->
            departments = _.groupBy(@allInterviews, (interview) -> interview.department)

            ret = []
            ret.fromObj departments

            ret.toMatrix(2)

        getChartData: ->
            data = []

            # Quick Fix
            _.each @value, (i) ->
                if !i.status and i.decided
                    i.status = 'needsAction'


            statuses = _.groupBy @value, (interview) -> interview.status

            for own key, interviews of statuses

                color = Math.floor(Math.random()*16777215)

                data.push {
                    value: interviews.length
                    label: if key is 'undefined' then 'unscheduled' else key
                    labelFontSize: 16
                    color: '#' + color.toString(16)
                    highlight: '#'+(color + 100).toString(16)
                }

            EJSON.stringify data
    }

)(Helpers.Client.TemplatesHelper.Handle('admin.hr.dashboard'))