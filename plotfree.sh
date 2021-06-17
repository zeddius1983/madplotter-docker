#!/bin/bash

function free_space() {
  echo $(df -B1 /final_dir | awk 'NR==2 { print $4 }')
}

function space_format() {
    echo $(numfmt --to iec --format "%8.2f" $1)
}

log() {
    echo $* | awk '{ print strftime("%c: "), $0; fflush(); }'
}

# Create plots until free space found
log "Start plotting..."

reqSpace=$space_per_plot
availSpace=$(free_space)
log "Total space available for plotting $(space_format $availSpace), space required per plot $(space_format $space_per_plot)"

while (( availSpace > reqSpace ))
do
    {
        #log "chia_plot -n 1 -r $threads -t /tmp_dir1 -d /final_dir -p $pool_key -f $farmer_key"
        ./chia_plot -n 1 -r $threads -t /tmp_dir1/ -d /final_dir/ -p $pool_key -f $farmer_key
    } 2>&1 | awk '{ print strftime("%c: "), $0; fflush(); }' | tee /logs_dir/plotfree-$(date +%F-%T).log
    availSpace=$((availSpace - reqSpace))
    log "Space remained $(space_format $availSpace) ($availSpace)"
    sleep 15
done

log "Stop plotting. Not enough free disk space."
exit 1