# mysql-slow

A pipeline for processing records in mysql's slow query log files, generated
by Scratchpads servers `sp-data-1` and `sp-data-2`.

## Setup

You will need Python 3.6.1 or later and R 3.3.3 or later.

```
mkvirtualenv mysql-slow
pip install -r requirements.pip
Rscript --slave --no-save --no-restore-history -e "install.packages('xts')"
```

Set the locations of the `python3` and `Rscript` binaries in `stages.py`.

## Run the analysis

1. Compress `mysql-slow` logs on `sp-data-1` and `sp-data-2`.

    `ssh` to each server and run

    ```
    sudo cp /var/log/mysql/mysql-slow.log . && \
        sudo chown lawh:lawh mysql-slow.log && \
        mv mysql-slow.log mysql-slow-`hostname`.log && \
        gzip mysql-slow-`hostname`.log
    ```

2. `scp` compressed logs from to `0_data`.

    On your workstation

    ```
    scp sp-data-1:/home/lawh/mysql-slow-sp-data-1.log.gz 0_data
    scp sp-data-2:/home/lawh/mysql-slow-sp-data-2.log.gz 0_data
    ```

3. Remove the compressed files from both `sp-data-1` and `sp-data-2`

    `ssh` to each server and run

    ```
    rm mysql-slow-`hostname`.log
    ```

4. Run the pipeline and view the results

    On your workstation

    ```
    workon mysql-slow
    somerset.py -R && somerset.py all
    open 4_visualise/*png
    ```
