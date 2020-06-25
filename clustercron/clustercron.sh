#!/bin/bash

## pve-clustercron
## Simple attempt at creating cluster wide cron jobs

##  
##  MIT License
##  
##  Copyright (c) 2020 conray (https://github.com/conraythefirst/pve-clustercron)
##  
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##  
##  The above copyright notice and this permission notice shall be included in all
##  copies or substantial portions of the Software.
##  
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##  SOFTWARE.


WAITLIMIT=59
ACTIVEFILE=$( dirname $0)/.master
HOSTNAME=$(hostname)

function am_i_active {
    FILECONTENT=$(<$ACTIVEFILE)
    
    if [ "$HOSTNAME" == "$FILECONTENT" ];then
    	exit 0
    else
    	exit 1
    fi
}

function get_master {
    MASTER=$(<$ACTIVEFILE)
    echo Active cron node: $MASTER
}

function select_master {
    # relying on working ha-manager by default
    HA_MASTER=$(ha-manager status | grep 'master' | awk '{print $2}')
    if [ -z "$HA_MASTER" ];then
        # HA is not configured
        # selecting the master by random sleep "race"
        select_active_node
    elif [ "$HA_MASTER" == "$HOSTNAME" ];then
        # HA is running
        echo "$HA_MASTER" > $ACTIVEFILE
    fi
}

function select_active_node {
    WAITLIMIT=${WAITLIMIT:=59}
    
    # sleep limited random seconds
    WAIT=$[ $RANDOM % $WAITLIMIT ]
    sleep $WAIT
    
    # get timestamps
    FILEAGE=$(stat -c %Y $ACTIVEFILE)
    FILEAGE=${FILEAGE:=0}
    TS=$(date +%s)
        
    # become active node when first finishing sleep
    if [[ "$[$TS - $FILEAGE]" -gt "$WAIT" ]]; then
        echo $HOSTNAME > $ACTIVEFILE
    fi
}

function usage {
    echo "clustercron.sh [select|status|isactive]"
    echo "    select   - select master node"
    echo "               if HA is configured then ha-manager is used"
    echo "               otherwise it's selected by random "
    echo "    status   - return current master node"
    echo "    isactive - return ture if master, false if not"
}

case "$1" in
    "select")
        select_master 
        ;;
    "isactive")
        am_i_active 
        ;;
    "status")
        get_master 
        ;;
    *)
        usage
        ;;
esac


