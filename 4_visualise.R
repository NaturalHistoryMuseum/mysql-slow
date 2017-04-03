#!/usr/bin/env Rscript
library(xts)

input.dir <- '3_rds'
output.dir <- '4_visualise'


FormatThousands <- function(v) {
    return (format(v, big.mark=','))
}

FormatN <- function(v) {
    return (paste0('(n=', FormatThousands(v), ')'))
}

PlotRawData <- function(host, log, ...) {
    # Raw datat, highlighting queries on certain schemas
    important.date <- as.POSIXct(
        as.Date(c(
            Something='2016-06-23',
            'Release 2.9.1'='2015-10-10',
            'Interactions to sp-data-1'='2017-03-29')
    ))

    col <- rep('#00000044', nrow(log))
    col['hostsmyspeciesin' == log$schema] <- '#ff00ff'
    col['mysql' == log$schema] <- '#0080ff'

    plot(
        log$datetime, log10(log$seconds_elapsed), xlab='Date', ylab=~log[10]~(seconds),
        pch=19, cex=0.5, col=col,
        main=paste0(host, ' slow sql queries ', FormatN(nrow(log))),
        ...
    )
    abline(v=important.date)
    mtext(text=format(important.date, format='%Y-%m-%d'), at=important.date)
}

PlotTimeOfDayDistribution <- function(host, log, threshold=0, ...) {
    # Distribution of times of day
    if(threshold>0) {
        log <- log[log$seconds_elapsed>180,]
        main <- paste0(
            host,
            ' time of day of sql queries slower than ',
            threshold, 's ', FormatN(nrow(log))
        )
    } else {
        main <- paste0(
            host,
            ' time of day of slow sql queries ', FormatN(nrow(log))
        )
    }
    hour <- as.numeric(substr(as.character(log$datetime), 12, 13))
    minute <- as.numeric(substr(as.character(log$datetime), 15, 16))
    t <- hour + minute/60
    plot(density(t), xlim=c(0, 24), main=main)

    rug(t)
}

PlotSlowest <- function(host, log, ...) {
    # Distribution of times of day
    # At least one row has no time
    log <- log[0 != log$seconds_elapsed,]

    ts <- xts(log10(log$seconds_elapsed), log$datetime)

    daily <- apply.daily(ts, max)
    weekly <- apply.weekly(ts, max)
    monthly <- apply.monthly(ts, max)

    par(mfrow=c(3, 1))
    ylim <- range(ts)
    plot(daily, main=paste0('Daily', FormatN(nrow(daily))), ylim=ylim)
    plot(weekly, main=paste0('Weekly', FormatN(nrow(weekly))), ylim=ylim)
    plot(monthly, main=paste0('Monthly', FormatN(nrow(monthly))), ylim=ylim)
    title(main=paste0('Slowest logs for ', host), outer=TRUE)
}


rds.files <- list.files(input.dir, pattern='*.rds$', full.names=TRUE)
logs <- lapply(rds.files, readRDS)
names(logs) <- sapply(strsplit(basename(rds.files), '\\.'), head, 1)

png(file.path(output.dir, 'raw_data.png'), width=1200, height=600 * length(logs))
par(mfrow=c(length(logs), 1))
junk <- mapply(PlotRawData, names(logs), logs, MoreArgs=list(ylim=c(0.1, 5.3)))
dev.off()

png(file.path(output.dir, 'time_of_day.png'), width=1200, height=600 * length(logs))
par(mfrow=c(length(logs), 1))
junk <- mapply(PlotTimeOfDayDistribution, names(logs), logs)
dev.off()

png(file.path(output.dir, 'time_of_day_three_minutes.png'), width=1200, height=600 * length(logs))
par(mfrow=c(length(logs), 1))
junk <- mapply(PlotTimeOfDayDistribution, names(logs), logs, threshold=180)
dev.off()


junk <- mapply(names(logs), logs, FUN=function(host, log) {
    png(
        file.path(output.dir, paste0('slowest-', host, '.png')),
        width=1200,
        height=1200
    )
    PlotSlowest(host, log, threshold=180)
    dev.off()
})

