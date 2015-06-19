class @Fixture.Departments extends Fixture.Base

    @_collection: InterviewScheduler.Collections.Department._collection

    @_uniqueFilter: (u) ->
        {
            name: u.name
        }

    @_data: [
        {
            name: 'Engineering'
        },
        {
            name: 'QA'
        },
        {
            name: 'Design'
        },
        {
            name: 'Product'
        },
        {
            name: 'BI'
        },
        {
            name: 'Mobile'
        },
        {
            name: 'SysOps'
        },
        {
            name: 'Seller Centre'
        }
    ]