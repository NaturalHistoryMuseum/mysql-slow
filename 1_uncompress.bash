for logfile in slow-sp-data-1.log slow-sp-data-2.log; do
    if [ -f 0_data/$logfile ]; then
        rm 0_data/$logfile
    fi
    gunzip -f 0_data/$logfile.gz
done
