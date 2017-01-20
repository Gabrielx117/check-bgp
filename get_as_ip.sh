#!/bin/bash
PWD=$(dirname `readlink -f "$0"`)/
cd $PWD
DEBUG="0" # 1 on, 0 off
aspath=$1
asip="as_iplist"
as_cmd="as_cmd"
loopback='220.113.135.52'
device_type='mx960'
keyword='BGP'
username="xiayu"
passwd="tjgwbn123"
sh ./create_new_command -A $aspath  > $as_cmd
python ./run.py $as_cmd $loopback  $device_type $keyword master $username $passwd > $asip
cat $asip | grep \/ | sort -n | uniq
if [ $DEBUG == 0 ]; then
    rm $as_cmd
fi
