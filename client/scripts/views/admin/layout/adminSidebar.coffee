((template) =>

    template.rendered = ->
        initSbAdmin()

    template.helpers {
        'refresh': ->
            Session.get('refresh')
    }

)(Template['adminSidebar'])