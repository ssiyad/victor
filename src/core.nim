import std/[os, times, strutils, options, strformat]

import database
import table
import help

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

proc prettyDuration (d: Duration): string =
    let p = d.toParts()
    if p[Weeks] != 0:
        return &"{p[Weeks]} weeks, {p[Days]} days"
    elif p[Days] != 0:
        return &"{p[Days]} days, {p[Hours]} hours"
    elif p[Hours] != 0:
        return &"{p[Hours]} hours, {p[Minutes]} minutes"
    elif p[Minutes] != 0:
        return &"{p[Minutes]} minutes, {p[Seconds]} seconds"
    else:
        return $(d)

proc echoTable (l: seq[Log]): void =
    var e: seq[Event]
    for i, v in l:
        if v.isLogin:
            add(e, Event(startLog: v, endLog: if i+1 == len(l): Log() else: l[i+1]))
    if len(e) == 0:
        quit("Nothing to show", 0)
    var t = newTable(@["SL", "Event", "Start", "End", "Duration"])
    for i, v in e:
        var r = TableRow(
            column: @[
                $(i+1),
                v.startLog.note.get(""),
                v.startLog.date.toTime().format("hh:mm tt", zone = local()),
                if isInitialized(v.endLog.date):
                    v.endLog.date.toTime().format("hh:mm tt", zone = local())
                else:
                    "",
                prettyDuration((if isInitialized(v.endLog.date): v.endLog.date else: now()) - v.startLog.date),
            ]
        )
        addToTable(t, r)
    t.show
    if len(e) > 1:
        echo "Total: ", prettyDuration(calcTimeSpent(l))

proc coreIn *(): void =
    let logLast = getLogLastOne().get(Log())
    if logLast.isLogin:
        "You are already logged in".quit(2)
    if paramCount() < 2:
        help()
        quit(1)
    let note = some(paramStr(2))
    var l = createLog(now(), true, note)
    insertLog(l)
    echo "You are now logged in"

proc coreOut *(): void =
    let logLast = getLogLastOne().get(Log())
    if not logLast.isLogin:
        "You are already logged out".quit(2)
    var l = createLog(now(), false)
    insertLog(l)
    echo "You are now logged out of \"", logLast.note.get(), "\""

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
    let l = getLogLastDay()
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
