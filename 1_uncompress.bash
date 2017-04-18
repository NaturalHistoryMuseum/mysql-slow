for archive in `find 0_data -type f -name *gz`; do
    logfile=${archive%.*}
    if [ -f $logfile ]; then
        rm $logfile
    fi
    gunzip $archive
done
