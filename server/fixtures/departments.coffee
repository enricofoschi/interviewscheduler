class @Fixture.Departments extends Fixture.Base

    @_collection: InterviewScheduler.Collections.Department._collection

    @_uniqueFilter: (u) ->
        {
            name: u.name
        }

    @_data: [
        {
            name: 'IT'
        },
        {
            name: 'QA'
        },
        {
            name: 'Seller Centre'
        }
    ]