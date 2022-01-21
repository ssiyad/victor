import std/[os, logging, with, options, times, algorithm, strformat]
import norm/[sqlite, model]

let db* = open(joinPath(getHomeDir(), ".victor.db"), "", "", "")

type Log * = ref object of Model
    date*: DateTime
    isLogin*: bool
    note*: Option[string]

addHandler(newConsoleLogger(fmtStr = ""))

proc createLog *(date: DateTime, isLogin: bool, note = none(string)): Log =
    Log(date: date, isLogin: isLogin, note: note)

proc insertLog *(log: var Log): void =
    with db:
        insert(log)

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
        select(l, "date > ?", d.toTime().toUnix())
    l

proc getLogLastDay *(): seq[Log] =
    var l = @[Log()]
    let today = now().format("yyyy-MM-dd")
    with db:
        select(
            l,
            "datetime(date, 'unixepoch', 'localtime') LIKE ?",
            &"{today}%",
        )
    l

proc createTables *() =
    db.createTables(createLog(now(), true))
