((template) =>

    Meteor.startup ->
        TabularTables.InitTemplate(template, 'Interviews')

)(Helpers.Client.TemplatesHelper.Handle('admin.interview.all'))