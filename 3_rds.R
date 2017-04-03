#!/usr/bin/env Rscript
# Writes .rds files of CSVs
input.dir <- '2_csv'
output.dir <- '3_rds'

if(!file.exists(output.dir)) dir.create(output.dir)

for(path in list.files(input.dir, pattern='*.csv$', full.names=TRUE)) {
    cat('Reading [', path, ']\n', sep='')
    log <- read.csv(path)

    rds.path <- file.path(
        output.dir,
        paste0(head(strsplit(basename(path), '\\.')[[1]], 1), '.rds')
    )
    log$datetime <- as.POSIXct(
        as.character(log$datetime), format='%Y-%m-%d %H:%M:%S'
    )

    cat('Writing [', rds.path, ']\n', sep='')
    saveRDS(log, file=rds.path)
}
