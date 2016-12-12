`Usage (script) : ./ToDo.sh  {FUNCTION} [OPTIONS] [ARGUMENTS]
Usage (command): Todo {FUNCTION} [OPTIONS] [ARGUMENTS]

                                            This Tool gives you a ToDo list on your command line. You are able to
                                            show the list, add entries, edit entries and delete entries.
                                            The Tool works with '.list' files. The default is the file 'ticket.list'
                                            and is actual stored in the same path as the script, but you can also 
                                            specify an other list file by argument within every command.

FUNCTIONS:
    show                                    show coloured (human-readable) ToDo list
                                                required arguments: none
                                                optional arguments: none

    add                                     add new item to ToDo list
                                                required arguments: (--ticket) or (--status, --customer, --ticketno)
                                                optional arguments: --description, --comment

    edit                                    edit existing ToDo list item
                                                required arguments: --index
                                                optional arguments: --status, --customer, --ticketno, --description, --comment

    delete                                  delete existing ToDo list item
                                                required arguments: --index
                                                optional arguments: none

    sort                                    sort ToDo list by status (backup file will be created)
                                                required arguments: none
                                                optional arguments: none

    register                                register this tool as bash command
                                                required arguments: none
                                                optional arguments: none

    help                                    show this help

OPTIONS:
    --silent | -s                           Make modifications without asking

    --debug  | -D                           Get full debug output.

ARGUMENTS:
    --filename=(string)                     (optional) Define an other list file. Absolute path is required.

    --index=(string)                        ticket number as index to edit or delete a specific ToDo list item

    --ticket=(string)                       Value for complete ToDo list item. The string should include at least the first three 
                                            parameters: status, customer, ticketnumber. Every ToDo list item requires the ticket
                                            number as an index.
                                            The parameters are separated with ":".
                                            Possible parameters "STATUS:CUSTOMER:TICKETNUMBER:DESCRIPTION:COMMENT"
                                            E.g. "X:Testcustomer:#12345:my description:any comment"

    --status=(string)                       Value for status code. If ticket argument is given, this will be ignored.
                                            possible Values:
                                                X = Live
                                                R = Ready (to go live)
                                                W = Work in Progress
                                                O = Open
                                                D = Declined

    --customer=(string)                     Value for customer name. If ticket argument is given, this will be ignored.

    --ticketno=(string)                     Value for ticket number. If ticket argument is given, this will be ignored.

    --description=(string)                  Value for description. If ticket argument is given, this will be ignored.

    --comment=(string)                      Value for comment. If ticket argument is given, this will be ignored.`
