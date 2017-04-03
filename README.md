## Setup

```
mkvirtualenv mysql-slow
pip install -r requirements.pip
Rscript --slave --no-save --no-restore-history -e "install.packages('xts')"
```

## Fetch logs

`scp` compressed `mysql-slow` logs from `sp-data-1` and `sp-data-2`.

1. `ssh` to each server and run

    ```
    sudo cp /var/log/mysql/mysql-slow.log . && \
        sudo chown lawh:lawh mysql-slow.log && \
        mv mysql-slow.log mysql-slow-`hostname`.log && \
        gzip mysql-slow-`hostname`.log 
    ```

2. On your workstation

    ```
    scp sp-data-1:/home/lawh/mysql-slow-sp-data-1.log.gz 0_data
    scp sp-data-2:/home/lawh/mysql-slow-sp-data-2.log.gz 0_data
    ```

3. `ssh` to each servers and remove the compressed files from `sp-data-1` and
    `sp-data-2`

    ```
    rm mysql-slow-`hostname`.log 
    ```

## Run the analysis

```
somerset all
open 4_visualise/*png
```
