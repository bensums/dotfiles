PATH="$HOME/miniconda3/bin:$PATH"
PATH="$HOME/.gem/ruby/2.1.0/bin:/usr/local/heroku/bin:$PATH"
PATH="$HOME/.rbenv/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/local/bin:$PATH"
export WORKON_HOME=~/Envs
source /usr/bin/virtualenvwrapper.sh
export HALCYON_BASE=$HOME/.halcyon/base
EDITOR="vim"
VISUAL="gvim --remote"
RSENSE_HOME="$HOME/opt/rsense"
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi
export R_LIBS="/home/ben/R/x86_64-pc-linux-gnu-library/3.2"
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt histignorespace
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ben/.zshrc'

# zsh NOMATCH option:
# If a pattern for filename generation has no matches, print an error, instead
# of leaving it unchanged in the argument list. This also applies to file
# expansion of an initial ~ or =.  We disable this so we can run rake tasks
# with arguments like rake f[x]. With nomatch set, this would have to be
# written rake f\[x\].
unsetopt nomatch

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U promptinit
promptinit
prompt grml
#prompt bart

# AWS autocompletion (from https://raw.githubusercontent.com/aws/aws-cli/develop/bin/aws_zsh_completer.sh)
source ~/.zsh/aws_zsh_completer.sh

LESS='-R'
LESSOPEN='|~/.lessfilter %s'

function greppy () {
    find . -type f -name '*.py' | xargs grep --colour $1
}
eval "$(rbenv init -)"

function queries () {
    # Show postgres queries running on database $1.
    # Args:
    # $1: database name
    watch -n1 "psql -U postgres -c 'SELECT datname,usename,pid,client_addr,waiting,query_start,query FROM pg_stat_activity;'"
}

function redis-del () {
    # Usage redis-del key_pattern [database_number]
    echo Deleting keys $1 from database ${2:=0}
    redis-cli -n ${2:=0} KEYS "$1" | tr "\n" "\0" | xargs -0 redis-cli -n ${2:=0} DEL
}

function commits () {
    git log --oneline | head
}

function db_size () {
DATABASE=${1:-ib_collector}
echo Largest 20 relations in $DATABASE:
psql -d $DATABASE -U postgres -c "SELECT nspname || '.' || relname AS \"relation\",                        pg_size_pretty(pg_relation_size(C.oid)) AS \"size\"                                 FROM pg_class C                                                                       LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') ORDER BY pg_relation_size(C.oid) DESC LIMIT 20;"
        }

# Battery stuff (prolongs battery life by only charging once drop below 40% and stop once gets to 80%.
function set_battery_thresholds {
    if [ -f /sys/devices/platform/smapi/BAT0/start_charge_thresh ]; then
        # tp_smapi way:
        echo ${1:-40} | sudo tee /sys/devices/platform/smapi/BAT0/start_charge_thresh
        echo ${1:-40} | sudo tee /sys/devices/platform/smapi/BAT1/start_charge_thresh
        echo ${2:-80} | sudo tee /sys/devices/platform/smapi/BAT0/stop_charge_thresh
        echo ${2:-80} | sudo tee /sys/devices/platform/smapi/BAT1/stop_charge_thresh
    else
        # tpacpi-bat way:
        sudo tpacpi-bat -v -s stopThreshold 0 ${2:-80}
        sudo tpacpi-bat -v -s stopThreshold 1 ${2:-80}
        sudo tpacpi-bat -v -s startThreshold 0 ${1:-40}
        sudo tpacpi-bat -v -s startThreshold 1 ${1:-40}
    fi
}
alias thresholds_on="set_battery_thresholds"
alias thresholds_off="set_battery_thresholds 95 99"

update_warning.py
backup_warning.py

