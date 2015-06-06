((template) =>

    Meteor.startup ->
        TabularTables.InitTemplate(template, 'Admins')

)(Template['admin.admins.all'])