#!/bin/bash
#
# @name ToDo
# @description Commandline ToDo Tool
# @author Ralph Dittrich <kizetsu.rd@googlemail.com>
# @version v0.1.2.31
VERSION='v0.1.2.31'
REPOSITORY='https://github.com/kizetsu/todo-command'
VERSIONFILE='https://raw.githubusercontent.com/kizetsu/todo-command/master/version.md'
COREFILE='https://raw.githubusercontent.com/kizetsu/todo-command/master/ToDo.sh'

# prepare defaults
LISTFILE="${HOME}/ticket.list"
declare -A OPTIONS
declare -A PARAMETERS

# display usage
function usage {
    cat <<-EOF
Usage (script) : ./ToDo.sh  {FUNCTION} [OPTIONS] [ARGUMENTS]
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

    update                                  update this tool to the latest version
                                                required arguments: none
                                                optional arguments: none

    help                                    show this help

OPTIONS:
    --silent | -S                           Make modifications without asking

    --debug  | -D                           Get full debug output.

ARGUMENTS:
    --file=(string)                         (optional) Define an other list file. Absolute path is required.

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

    --comment=(string)                      Value for comment. If ticket argument is given, this will be ignored.


EOF
}

function getArguments {
    for p in "$@"; do
        case "$p" in
            --silent|-S)
                OPTIONS[silent]=true
                ;;
            --verbose|-V)
                OPTIONS[verbose]=true
                ;;
            --debug|-D)
                OPTIONS[debug]=true
                ;;
            --file=*)
                tmpfilename="${p/--file=/}"
                PARAMETERS[filename]="${tmpfilename/\"/}"
                ;;
            --index=*)
                tmpindex="${p/--index=/}"
                PARAMETERS[index]="${tmpindex/\"/}"
                ;;
            --ticket=*)
                tmpticket="${p/--ticket=/}"
                PARAMETERS[ticket]="${tmpticket/\"/}"
                ;;
            --status=*)
                tmpstatus="${p/--status=/}"
                PARAMETERS[status]="${tmpstatus/\"/}"
                ;;
            --customer=*)
                tmpcustomer="${p/--customer=/}"
                PARAMETERS[customer]="${tmpcustomer/\"/}"
                ;;
            --ticketno=*)
                tmpticketno="${p/--ticketno=/}"
                PARAMETERS[ticketno]="${tmpticketno/\"/}"
                ;;
            --description=*)
                tmpdesc="${p/--description=/}"
                PARAMETERS[description]="${tmpdesc/\"/}"
                ;;
            --comment=*)
                tmpcomm="${p/--comment=/}"
                PARAMETERS[comment]="${tmpcomm/\"/}"
                ;;
        esac
    done
}

function debug {
    echo "DEBUG: $@"
}

function show {
    # check if file exist
    if [ ! -f ${PARAMETERS[filename]} ]; then
        echo "ERROR: missing list file at ${PARAMETERS[filename]}"
        exit 1
    fi

    # prepare output
    echo -e "STATUS\t\tCUSTOMER\tTICKETNUMMER\tDESCRIPTION\t\t\t\t\tCOMMENT"
    echo -e "------\t\t--------\t------------\t-----------\t\t\t\t\t-------"
    while read line; do
        POINTER=0
        STAT=''
        CUST=''
        TICK=''
        DESC=''
        COM=''
        # get status
        STAT="${line:0:1}"
        POINTER=`expr ${#STAT} + 1`
        case "$STAT" in
            X|x)
                STAT="\\033[1;32mLIVE\\033[0m\t"
                ;;
            R|r)
                STAT="\\033[1;34mREADY\\033[0m\t"
                ;;
            W|w)
                STAT="\\033[1;33mWIP\\033[0m\t"
                ;;
            O|o)
                STAT="\\033[1;31mOPEN\\033[0m\t"
                ;;
            D|d)
                STAT="\\033[1;35mDECLINED\\033[0m"
                ;;
        esac
        # get customer
        CUST="${line:2}"
        CUST="${CUST/:*/}"
        POINTER=`expr $POINTER + ${#CUST} + 1`
        if [ ${#CUST} -lt 8 ]; then
            CUST="$CUST\t"
        fi
        # get ticket number
        TICK="${line:$POINTER}"
        TICK="${TICK/:*/}"
        POINTER=`expr $POINTER + ${#TICK} + 1`
        if [ ${#TICK} -lt 8 ]; then
            TICK="$TICK\t"
        fi
        # get description
        DESC="${line:$POINTER}"
        DESC="${DESC/:*/}"
        POINTER=`expr $POINTER + ${#DESC} + 1`
        if [ ${#DESC} -lt 8 ]; then
            DESC="$DESC\t\t\t\t\t"
        elif [ ${#DESC} -lt 16 ]; then
            DESC="$DESC\t\t\t\t"
        elif [ ${#DESC} -lt 24 ]; then
            DESC="$DESC\t\t\t"
        elif [ ${#DESC} -lt 32 ]; then
            DESC="$DESC\t\t"
        elif [ ${#DESC} -lt 40 ]; then
            DESC="$DESC\t"
        fi
        # get comment
        COM="${line:$POINTER}"
        COM="${COM/:*/}"
        # ouput informations
        echo -e "${STAT}\t${CUST}\t${TICK}\t${DESC}\t${COM}"
    done < "${PARAMETERS[filename]}"
    return 0
}

function add {
    # check if file exist
    if [ ! -f ${PARAMETERS[filename]} ]; then
        echo "missing list file"
        command touch ${PARAMETERS[filename]} > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "ERROR: could not create file for ${PARAMETERS[filename]}"
            exit 1
        fi
    fi

    # check if at least one required parameter is given
    if [[ ${PARAMETERS[ticket]} == '' ]]; then
        if [[ ${PARAMETERS[status]} == '' ]] || [[ ${PARAMETERS[customer]} == '' ]] || [[ ${PARAMETERS[ticketno]} == '' ]]; then
            usage
            exit 1
        fi
        PARAMETERS[ticket]="${PARAMETERS[status]}:${PARAMETERS[customer]}:${PARAMETERS[ticketno]}:${PARAMETERS[description]}:${PARAMETERS[comment]}"
    fi

    # write to list
    echo "INFO: write '${PARAMETERS[ticket]}' to '${PARAMETERS[filename]}'"
    echo "${PARAMETERS[ticket]}" >> ${PARAMETERS[filename]}
    return 0
}

function edit {
    # check if file exist
    if [ ! -f ${PARAMETERS[filename]} ]; then
        echo "ERROR: missing list file at ${PARAMETERS[filename]}"
        exit 1
    fi

    # declare variables
    userrow=''      # full row with userparams
    origrow=''      # full row from $line

    # if no ticket number is given, we have no index and exit
    if [[ ${PARAMETERS[index]} == '' ]]; then
        echo "no index given"
        return 1
    fi
    # check if at least one parameters is given
    if [[ ${PARAMETERS[status]} == '' ]] && [[ ${PARAMETERS[customer]} == '' ]] && 
        [[ ${PARAMETERS[ticketno]} == '' ]] && [[ ${PARAMETERS[description]} == '' ]] && 
        [[ ${PARAMETERS[comment]} == '' ]]; then
        echo "no values given"
        return 1
    fi

    # check list file for given index
    while read line; do
        POINTER=0
        TICK=''
        INDEX=''
        # get status index
        INDEX="${line/:*/}."
        POINTER=`expr ${#INDEX}`
        # get customer index
        INDEX="$INDEX${line:POINTER}"
        INDEX="${INDEX/:*/}."
        POINTER=`expr ${#INDEX}`
        # get ticket number
        TICK="${line:$POINTER}"
        TICK="${TICK/:*/}"
        TICK="${TICK/#/}"
        if [[ $TICK == *${PARAMETERS[index]}* ]]; then
            origrow=$line
            userrow=$line
            break
        fi
    done < "${PARAMETERS[filename]}"

    # check if index matched a row
    if [[ $origrow == '' ]]; then
        echo "no item found by index: ${PARAMETERS[index]}"
        exit 1
    fi

    # set new status if given
    INDEX="${origrow/:*/}"
    POINTER=`expr ${#INDEX} + 1`
    if [[  ${PARAMETERS[status]} != '' ]]; then
        replace="${PARAMETERS[status]}"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "status"
            debug "   - userrow:     $userrow"
            debug "   - pointer:     $POINTER"
            debug "   - search:      $INDEX"
            debug "   - replacement: $replace"
            debug " "
        fi
        userrow="${userrow/$INDEX/$replace}"
    fi
    # set new customer if given
    INDEX="${origrow:$POINTER}"
    INDEX="${INDEX/:*/}"
    POINTER=`expr $POINTER + ${#INDEX} + 1`
    if [[ ${PARAMETERS[customer]} != '' ]];then
        replace="${PARAMETERS[customer]}"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug " customer"
            debug "   - userrow:     $userrow"
            debug "   - pointer:     $POINTER"
            debug "   - search:      $INDEX"
            debug "   - replacement: $replace"
            debug " "
        fi
        userrow="${userrow/$INDEX/$replace}"
    fi
    # set new ticket number if given
    INDEX="${origrow:$POINTER}"
    INDEX="${INDEX/:*/}"
    POINTER=`expr $POINTER + ${#INDEX} + 1`
    if [[ ${PARAMETERS[ticketno]} != '' ]];then
        replace="${PARAMETERS[ticketno]}"
        INDEX="${INDEX/\#/\\\#}"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "ticketno"
            debug "   - userrow:     $userrow"
            debug "   - pointer:     $POINTER"
            debug "   - search:      $INDEX"
            debug "   - replacement: $replace"
            debug " "
        fi
        userrow="${userrow/$INDEX/$replace}"
    fi
    # set new description if given
    INDEX="${origrow:$POINTER}"
    INDEX="${INDEX/:*/}"
    POINTER=`expr $POINTER + ${#INDEX} + 1`
    if [[ ${PARAMETERS[description]} != '' ]]; then
        replace="${PARAMETERS[description]}"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "description"
            debug "   - userrow:     $userrow"
            debug "   - pointer:     $POINTER"
            debug "   - search:      $INDEX"
            debug "   - replacement: $replace"
            debug " "
        fi
        userrow="${userrow/$INDEX/$replace}"
    fi
    # set new comment if given
    INDEX="${origrow:$POINTER}"
    INDEX="${INDEX/:*/}"
    POINTER=`expr $POINTER + ${#INDEX} + 1`
    if [[ ${PARAMETERS[comment]} != '' ]]; then
        replace="${PARAMETERS[comment]}"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "comment"
            debug "   - userrow:     $userrow"
            debug "   - pointer:     $POINTER"
            debug "   - search:      $INDEX"
            debug "   - replacement: $replace"
            debug " "
        fi
        userrow="${userrow/$INDEX/$replace}"
    fi

    # if not silent: user may check the replacement
    echo -e "the entry \\033[1;33m'$origrow'\\033[0m will be replaced with \\033[1;33m'$userrow'\\033[0m"
    if [[ ${OPTIONS[silent]} != true ]]; then
        echo "do you want to continue? [y|n]"
        read -r -n 1 -s choice
    fi

    if [[ $choice == y ]] || [[ ${OPTIONS[silent]} == true ]]; then
        # change row with sed
        # echo "sed -ie \"s/$origrow/$userrow/g\" $LISTFILE"
        command cp "${PARAMETERS[filename]}" "${PARAMETERS[filename]}.bak"
        command sed -ie "s/$origrow/$userrow/g" "${PARAMETERS[filename]}" > /dev/null 2>&1
        # check if we got an error from sed
        if [[ $? -eq 0 ]]; then
            command rm "${PARAMETERS[filename]}.bak"
            echo "Success"
            return 0
        else
            command cp "${PARAMETERS[filename]}.bak" "${PARAMETERS[filename]}"
            command rm "${PARAMETERS[filename]}.bak"
            echo "ERROR: could not change list File. Changes have been reverted."
            return 1
        fi
    fi
    return 0
}

function delete {
    # check if file exist
    if [ ! -f ${PARAMETERS[filename]} ]; then
        echo "ERROR: missing list file at ${PARAMETERS[filename]}"
        exit 1
    fi

    # if no ticket number is given, we have no index and exit
    if [[ ${PARAMETERS[index]} == '' ]]; then
        echo "no index given"
        return 1
    fi

    # prepare local variable
    origrow=''

    # check list file for given index
    while read line; do
        POINTER=0
        TICK=''
        INDEX=''
        # get status index
        INDEX="${line/:*/}."
        POINTER=`expr ${#INDEX}`
        # get customer index
        INDEX="$INDEX${line:POINTER}"
        INDEX="${INDEX/:*/}."
        POINTER=`expr ${#INDEX}`
        # get ticket number
        TICK="${line:$POINTER}"
        TICK="${TICK/:*/}"
        TICK="${TICK/#/}"
        if [[ $TICK == *${PARAMETERS[index]}* ]]; then
            origrow=$line
            break
        fi
    done < "${PARAMETERS[filename]}"

    # if not silent: user may check the deletion
    echo -e "the entry \\033[1;33m'$origrow'\\033[0m will be deleted"
    if [[ ${OPTIONS[silent]} != true ]]; then
        echo "do you want to continue? [y|n]"
        read -r -n 1 -s choice
    fi

    if [[ $choice == y ]] || [[ ${OPTIONS[silent]} == true ]]; then
        # delete row with sed
        # echo "sed -ie '/$origrow/d" "${PARAMETERS[filename]}'"
        command cp "${PARAMETERS[filename]}" "${PARAMETERS[filename]}.bak"
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "SED command: sed -ie \"/$origrow/d\" \"${PARAMETERS[filename]}\""
        fi
        command sed -ie "/$origrow/d" "${PARAMETERS[filename]}" > /dev/null 2>&1
        # check if we got an error from sed
        if [[ $? -eq 0 ]]; then
            command rm "${PARAMETERS[filename]}.bak"
            echo "Success"
            return 0
        else
            command cp "${PARAMETERS[filename]}.bak" "${PARAMETERS[filename]}"
            command rm "${PARAMETERS[filename]}.bak"
            echo "ERROR: could not change list File. Changes have been reverted."
            return 1
        fi
    fi
    return 0
}

function sort {
    # check if file exist
    if [ ! -f ${PARAMETERS[filename]} ]; then
        echo "ERROR: missing list file at ${PARAMETERS[filename]}"
        exit 1
    fi

    # declare associative sort arrays
    declare -A LIVE
    declare -A READY
    declare -A WIP
    declare -A OPEN
    declare -A DECLINED

    # check list file for given index
    while read line; do
        POINTER=0
        TICK=''
        INDEX=''
        STAT=''
        # get status index
        INDEX="${line/:*/}."
        POINTER=`expr ${#INDEX}`
        STAT="${line/:*/}"
        # echo "STAT: ${STAT}"
        # get customer index
        INDEX="$INDEX${line:POINTER}"
        INDEX="${INDEX/:*/}."
        POINTER=`expr ${#INDEX}`
        # get ticket number
        TICK="${line:$POINTER}"
        TICK="${TICK/:*/}"
        TICK="${TICK/#/}"
        case "$STAT" in
            X|x)
                LIVE["$TICK"]="${line}"
                ;;
            R|r)
                READY["$TICK"]="$line"
                ;;
            W|w)
                WIP["$TICK"]="$line"
                ;;
            O|o)
                OPEN["$TICK"]="$line"
                ;;
            D|d)
                DECLINED["$TICK"]="$line"
                ;;
        esac
    done < "${PARAMETERS[filename]}"

    # @ToDo:
    # sort tickets by sort-param
    # how to get sort-param from tickets? nice simple way would be good

    # backup list file (mv because we want to get an empty list file)
    command mv "${PARAMETERS[filename]}" "${PARAMETERS[filename]}.bak"
    echo "Backup file created at ${PARAMETERS[filename]}.bak"

    # create empty list file
    command touch "${PARAMETERS[filename]}"

    if [[ ${OPTIONS[debug]} == true ]];then
        debug "Status: Live"
    fi
    # walk through TICKETLIST and echo to file
    for l in "${LIVE[@]}"; do
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "   $l"
        fi
        echo "$l" >> "${PARAMETERS[filename]}"
    done
    if [[ ${OPTIONS[debug]} == true ]];then
        debug "Status: Ready"
    fi
    for r in "${READY[@]}"; do
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "   $r"
        fi
        echo "$r" >> "${PARAMETERS[filename]}"
    done
    if [[ ${OPTIONS[debug]} == true ]];then
        debug "Status: Work in Progress"
    fi
    for w in "${WIP[@]}"; do
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "   $w"
        fi
        echo "$w" >> "${PARAMETERS[filename]}"
    done
    if [[ ${OPTIONS[debug]} == true ]];then
        debug "Status: Open"
    fi
    for o in "${OPEN[@]}"; do
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "   $o"
        fi
        echo "$o" >> "${PARAMETERS[filename]}"
    done
    if [[ ${OPTIONS[debug]} == true ]];then
        debug "Status: Declined"
    fi
    for d in "${DECLINED[@]}"; do
        if [[ ${OPTIONS[debug]} == true ]];then
            debug "   $d"
        fi
        echo "$d" >> "${PARAMETERS[filename]}"
    done
    echo "Done sorting"

}

function register {
    if [ -f '/bin/todo.sh' ]; then
        # we do not want to let the user register multiple times
        # later an update command may come
        echo "[ToDo List Tool] is already registered"
        echo "    For more information type: Todo help"
        return 0
    else
        # check if user is superuser
        command NET SESSION > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "register must be run as superuser"
            exit 1
        fi

        # copy todo.sh to /bin/todo.sh
        command cp "ToDo.sh" "/bin/todo.sh" > /dev/null 2>&1
        # check if the file can be created
        if [[ $? -eq 1 ]]; then
            echo "could not register [ToDo List Tool]"
            echo "Try again as superuser"
            return 1
        else
            BASHFILE=''
            # check which file exist
            if [ -f "${HOME}/.bash_aliases" ]; then
                BASHFILE="${HOME}/.bash_aliases"
            elif  [ -f "${HOME}/.bashrc" ]; then
                BASHFILE="${HOME}/.bashrc"
            else
                echo "WARNING: could not find wether .bash_aliases nor .bashrc"
                echo "    paste the following line to your bash source file and restart your console:"
                echo '    alias Todo="/bin/todo.sh"'
                return 0
            fi
            # write to bash file (hopefully .bash_aliases)
            if [[ ! $BASHFILE = '' ]]; then
                if [[ ${OPTIONS[debug]} == true ]];then
                    debug 'alias Todo="/bin/todo.sh" >> ${BASHFILE}'
                fi
                echo 'alias Todo="/bin/todo.sh"' >> "${BASHFILE}"
            fi
            echo "[ToDo List Tool] was successful registered"
            echo "INFO: please restart your console"
            echo ""
            echo "usage: Todo {FUNCTION} [OPTIONS] [ARGUMENTS]"
            echo "    For more information type: Todo help"
            return 0
        fi
    fi
}

function update {
    # check if user is superuser
    command NET SESSION > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "update must be run as superuser"
        exit 1
    fi

    # check if todo.sh is already registered in /bin/ folder
    if [ ! -f '/bin/todo.sh' ]; then
        echo "[ToDo List Tool] is not registered yet"
        echo 'use "./ToDo.sh register" to register [ToDo List Tool] as bash command'
        return 1
    else
        echo "checking for version..."
        # check if wget or curl is installed and get version file
        # we prefer wget
        command -v wget > /dev/null 2>&1
        chkwget=$?
        command -v curl > /dev/null 2>&1
        chkcurl=$?
        cd /tmp/
        if [ $chkwget -eq 0 ]; then
            # use wget
            command wget -O todo.version "$VERSIONFILE"
        elif [ $chkcurl -eq 0 ]; then
            # use curl
            command curl -o todo.version "$VERSIONFILE"
        else
            # manually check for version is required
            echo "could not get version from repository"
            echo "please manually check it at: ${REPOSITORY}"
            return 1
        fi

        #check if file could be downloaded
        if [ ! -f '/tmp/todo.version']; then
            # manually check for version is required
            echo "could not get version from repository"
            echo "please manually check it at: ${REPOSITORY}"
            return 1
        fi

        # get version from file
        REMOTEVERSION=''
        while read line; do
            REMOTEVERSION="${line}"
            break
        done < '/tmp/todo.version'
        command rm '/tmp/todo.version'

        # convert string to int
        # VAR="${VAR/v/}"
        # VAR="${VAR//\./}"
        # $((10#${VAR#0}))
        tmpVer="${VERSION/v/}"
        tmpVer="${tmpVer//\./}"
        tmpRemVer="${REMOTEVERSION/v/}"
        tmpRemVer="${tmpRemVer//\./}"
        # check if remote version is higher then local
        if [[ $((10#${tmpRemVer#0})) -gt $((10#${tmpVer})) ]]; then
            echo "found update"
            echo "downloading update..."
            if [ $chkwget -eq 0 ]; then
                # use wget
                command wget -O ToDo.sh "$COREFILE"
            elif [ $chkcurl -eq 0 ]; then
                # use curl
                command curl -o ToDo.sh "$COREFILE"
            fi
        else
            echo "[ToDo List Tool] is already the latest version"
            return 0
        fi

        # check if file could be downloaded
        if [ ! -f '/tmp/ToDo.sh']; then
            # manually check for update is required
            echo "could not get update from repository"
            echo "please manually download it from: ${REPOSITORY}"
            return 1
        fi

        # copy todo.sh to /bin/todo.sh
        command cp "ToDo.sh" "/bin/todo.sh" > /dev/null 2>&1
        # check if the file could be created
        if [[ $? -eq 1 ]]; then
            echo "could not update [ToDo List Tool]"
            echo "Please try again"
            return 1
        else
            echo "[ToDo List Tool] was successful registered"
            command rm '/tmp/ToDo.sh'
            return 0
        fi
    fi
}

function ToDo {

    # check if any parameter is given
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    # set defaults
    PARAMETERS[filename]=$LISTFILE
    OPTIONS[verbose]=false
    OPTIONS[silent]=false
    OPTIONS[debug]=false

    # get user parameters
    getArguments "${@:1}"

    # DEBUG ->
    if [[ ${OPTIONS[debug]} == true ]];then
        debug "-----"
        debug "parameters:"
        for p in "${!PARAMETERS[@]}"; do
            debug "   Key:   $p"
            debug "   Value: ${PARAMETERS[$p]}"
        done
        debug "-----"
    fi
    # DEBUG <-

    # call function
    case "$1" in
        show)
            show
            ;;
        add)
            add
            ;;
        edit)
            edit
            ;;
        delete)
            delete
            ;;
        sort)
            sort
            ;;
        help)
            usage
            ;;
        register)
            register
            ;;
        update)
            update
            ;;
        version)
            echo $VERSION
            exit 0
            ;;
        default)
            echo "ERROR: unknown function call"
            usage
            exit 1
            ;;
    esac

    exit
}

ToDo "$@"
