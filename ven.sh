# ven 0.1

function _ven_usage {
    case $1 in
        init)
            echo "init: initialize a new virtualenv container

Usage:
    ven init [<name>] [<virtualenv options>]

Note: The name defaults to name of the current directory"
            ;;
        list)
            echo "list: show all virtualenvs

Usage:
    ven list"
            ;;
        new)
            echo "new: make new virtualenv

Usage:
    ven new <name> [-i <virtualenv>] [-o <virtualenv options>]

Arguments:
    -i  Name of virtualenv to inherit from
    -o  Quoted arguments passed to virtualenv creation command"
            ;;
        switch)
            echo "switch: deactivate current virtualenv and activate another one

Usage: ven switch <name>"
            ;;
        delete)
            echo "delete: remove a virtualenv from the list

Usage: ven delete <name>"
            ;;
        help)
            echo "help: get help

Usage: ven help <command>"
            ;;
        *)
            if [ -z $1 ]; then
                echo "ven 0.1 - virtualenv manager

Subcommands:
    init - initialize a new virtualenv container
    list - show all virtualenvs
    new - make new virtualenv
    switch - deactivate current virtualenv and activate another one
    delete - remove a virtualenv from the list
    help - show this message

For help on a specific command, run 'ven help {command}'"
            else
                echo Command \"$1\" not recognized.
            fi
            ;;
    esac
}

function _ven_add {
    local name=$1
    grep -Fxq "$name" $(_ven_dir)/list || echo $name >> $(_ven_dir)/list
}

function _ven_new {
    local name=$1
    local opts=$2
    echo Creating virtualenv \"$name\"...
    echo Using virtualenv options $opts...
    virtualenv $opts $(_ven_dir)/$name
    _ven_add $name
    _ven_activate $name
}

function _ven_activate {
    local name=$1
    echo Activating \"$name\"...
    source $(_ven_dir)/$name/bin/activate
}
function _ven_dir {
    local dir
    if [ -n "$VEN_DIR" ]; then
        dir=$VEN_DIR
    else
        dir=`pwd`/.ven
    fi
    echo $dir
}

function _ven_check {
    local name=$1
    if [ -z $name ]; then
        if [ -f $(_ven_dir)/list ]; then
            return 0
        else
            return 1
        fi
    else
        if [ -d $(_ven_dir)/$name ]; then
            return 0
        else
            return 1
        fi
    fi
}

function ven {
    case $1 in
        init)
            if [ -d $(_ven_dir) ]; then
                echo ERROR: Ven is already initialized!
                return 1
            fi
            echo Initializing...
            mkdir $(_ven_dir)
            touch $(_ven_dir)/list
            local name=$2
            local virtualenv_opts=$3
            if [ -z $name ]; then
                name=$(basename `pwd`)
                echo Name not specified, defaulting to \"$name\".
            fi
            _ven_new $name "$virtualenv_opts"
            return 0
            ;;
        list)
            if ! _ven_check; then
                echo ERROR: Ven is not initialized!
                return 1
            fi
            cat $(_ven_dir)/list
            return 0
            ;;
        new)
            # reset getopts state
            OPTIND=
            local name=$2
            local base=
            if [ -z $name ]; then
                echo ERROR: Name of virtualenv required!
                return 1
            fi
            if _ven_check $name; then
                echo ERROR: Virtualenv \"$name\" already exists!
                return 1
            fi

            while getopts ":i:o:" OPTION ${*:3}
            do
                 case $OPTION in
                    i)
                        base=$OPTARG
                        echo "Using base virtualenv: \"$base\""
                        ;;
                    o)
                        local virtualenv_opts=$OPTARG
                        echo "Using virtualenv options: \"$virtualenv_opts\""
                        ;;
                    ?)
                        echo Invalid option!
                        return 1
                        ;;
                 esac
            done

            _ven_new $name $virtualenv_opts
            if [ -n "$base" ]; then
                local base_env=$($(_ven_dir)/$base/bin/python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
                local new_env=$($(_ven_dir)/$name/bin/python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
                echo $base_env > $new_env/ven.pth
            fi
            return 0
            ;;
        switch)
            local name=$2
            if [ -z $name ] ; then
                echo ERROR: Name of virtualenv required!
                return 1
            fi
            if ! _ven_check $name; then
                echo ERROR: Virtualenv \"$name\" does not exist!
                return 1
            fi
            if type deactivate > /dev/null 2>&1; then
                deactivate
            fi
            _ven_activate $name
            return 0
            ;;
        delete)
            local name=$2
            sed -i '' "/$name/d" $(_ven_dir)/list
            # TODO: add option -f (force) to delete the data too
            ;;
        help)
            _ven_usage $2
            return 0
            ;;
    esac
}

_ven_completion()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="init list new switch delete help"

    case "${prev}" in
        init)
            return 0
            ;;
        list)
            return 0
            ;;
        new)
            return 0
            ;;
        switch)
            local next=$(cat $(_ven_dir)/list)
            COMPREPLY=( $(compgen -W "${next}" -- ${cur}) )
            return 0
            ;;
        delete)
            local next=$(cat $(_ven_dir)/list)
            COMPREPLY=( $(compgen -W "${next}" -- ${cur}) )
            return 0
            ;;
        help)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _ven_completion ven
