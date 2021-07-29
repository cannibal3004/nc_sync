#!/bin/bash

function syncFolder() {
    if [[ ! -d $3 ]]; then
        echo "$(date +"%Y-%m-%d:%T"):: $3 is not available. Make sure to use absolute paths."
    else
        nextcloudcmd -u "$1" -p "$2" "$3" "$4" > /dev/null 2>&1
        if [[ $? != 0 ]]; then
            echo "$(date +"%Y-%m-%d:%T"):: Sync errored for folder: \"$SYNCPATH\"" >> ~/.nc_sync.log
        else
            echo "$(date +"%Y-%m-%d:%T"):: Sync completed successfully for folder: \"$SYNCPATH\"" >> ~/.nc_sync.log
        fi
    fi
}

if [[ ! -f /etc/nc_passwd && ! -f ~/.nc_passwd ]]; then
    echo "Credentials file not found. \"nc_passwd\" file must exist in /etc/nc_passwd or ~/.nc_passwd"
    exit 1
fi

if [[ -f ~/.nc_passwd ]]; then
    USERNAME=$(cat ~/.nc_passwd | cut -d ";" -f1)
    PASSWORD=$(cat ~/.nc_passwd | cut -d ";" -f2)
    if [[ $USERNAME == "" || $PASSWORD == "" ]]; then
        echo "Credentials file could not be parsed correctly."
        exit 1
    fi
else
    USERNAME=$(cat /etc/nc_passwd | cut -d ";" -f1)
    PASSWORD=$(cat /etc/nc_passwd | cut -d ";" -f2)
    if [[ $USERNAME == "" || $PASSWORD == "" ]]; then
        echo "Credentials file could not be parsed correctly."
        exit 1
    fi
fi

if [[ ! -f ~/.nc_sync ]]; then
    echo "Sync file not found. .nc_sync file must exist at ~/.nc_sync"
    exit 1
fi

SYNCLIST=$(cat ~/.nc_sync)

for SYNC in $SYNCLIST
do
    echo "SYNC = $SYNC"
    SYNCPATH=$(echo $SYNC | cut -d ";" -f1)
    URL=$(echo $SYNC | cut -d ";" -f2)
    syncFolder $USERNAME $PASSWORD $SYNCPATH $URL &
done

echo "$(expr ${#SYNCLIST[@]} + 1) Sync(s) initated."
