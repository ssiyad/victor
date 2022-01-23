import std/[os, logging, with, options, times, algorithm, strformat]
import norm/[sqlite, model]

let db* = open(joinPath(getHomeDir(), ".victor.db"), "", "", "")

type Log * = ref object of Model
    startAt*: Option[DateTime]
    endAt*: Option[DateTime]
    title*: string

addHandler(newConsoleLogger(fmtStr = ""))

proc insertLog *(log: var Log): void =
    with db:
        insert(log)

proc updateLog *(log: var Log): Log {.discardable.} =
    with db:
        update(log)
    log

proc getLogLast *(n: int): seq[Log] =
    var l = @[Log()]
    with db:
        # https://github.com/moigagoo/norm/blob/develop/src/norm/sqlite.nim#L174
        # It is not possible to have an empty WHERE condition at the moment
        select(l, "1 = 1 ORDER BY id DESC LIMIT ?", n)
    l.reversed()

proc getLogLastOne *(): Option[Log] =
    var l = getLogLast(1)
    if l.len() > 0:
        return some(pop(l))

proc getLogLastNMinute *(n: int): seq[Log] =
    var d = now() - initDuration(minutes = n)
    var l = @[Log()]
    with db:
        select(l, "startAt > ? OR endAt > ?", d.toTime().toUnix())
    l

proc getLogLastDay *(n: int): seq[Log] =
    getLogLastNMinute(n * 24 * 60)

proc getLogLastDay *(date: string): seq[Log] =
    var l = @[Log()]
    with db:
        select(
            l,
            "datetime(startAt, 'unixepoch', 'localtime') LIKE ? OR datetime(endAt, 'unixepoch', 'localtime') LIKE ?",
            &"{date}%",
        )
    l

proc createTables *() =
    db.createTables(Log())
