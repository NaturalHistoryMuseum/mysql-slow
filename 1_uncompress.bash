for archive in 0_data/*gz; do
    logfile=${archive%.*}
    if [ -f $logfile ]; then
        rm $logfile
    fi
    gunzip $archive
done
