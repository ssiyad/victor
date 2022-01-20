import std/[os, times, strutils, options]

import database
import table

createTables()

type Event = ref object
    startLog: Log
    endLog: Log

proc calcTimeSpent (l: seq[Log]): Duration =
    var d = initDuration()
    for i, v in l:
        if not v.isLogin:
            if i == 0: continue
            d = d + (v.date - l[i-1].date)
    d

proc echoTable (l: seq[Log]): void =
    var e: seq[Event]
    for i, v in l:
        if v.isLogin:
            if i + 1 == len(l): continue
            add(e, Event(startLog: v, endLog: l[i+1]))
    if len(e) == 0:
        quit("Nothing to show", 0)
    var t = newTable(@["SL", "Event", "Start", "End", "Duration"])
    for i, v in e:
        var r = TableRow(
            column: @[
                $(i+1),
                v.startLog.note.get(""),
                v.startLog.date.format("HH:MM"),
                v.endLog.date.format("HH:MM"),
                $(v.endLog.date - v.startLog.date),
            ]
        )
        addToTable(t, r)
    t.show
    if len(e) > 1:
        echo "Total: ", calcTimeSpent(l)

proc coreIn *(): void =
    let logLast = getLogLastOne().get(Log())
    if logLast.isLogin:
        "You are already logged in".quit(2)
    var note: Option[string]
    if paramCount() >= 2:
        note = some(paramStr(2))
    var l = createLog(now(), true, note)
    insertLog(l)
    echo "You are now logged in"

proc coreOut *(): void =
    let logLast = getLogLastOne().get(Log())
    if not logLast.isLogin:
        "You are already logged out".quit(2)
    var note: Option[string]
    if paramCount() >= 2:
        note = some(paramStr(2))
    var l = createLog(now(), false, note)
    insertLog(l)
    echo "You are now logged out"

proc logLast(): void =
    var n: int = 10
    try:
        n = parseInt(paramStr(2))
    except: discard
    let l = getLogLast(n)
    echoTable(l)

proc logLastHour(): void =
    let l = getLogLastNMinute(60)
    echoTable(l)

proc logLastDay(): void =
    let l = getLogLastNMinute(1440)
    echoTable(l)

proc coreLog *(): void =
    var timespan: string
    if paramCount() < 2:
        timespan = "day"
    else:
        timespan = paramStr(2)
    case timespan
    of "hour":
        logLastHour()
    of "day":
        logLastDay()
    else:
        logLast()
