import std/[os, times, strutils, options, strformat]

import database
import table
import help

createTables()

proc calcTimeSpent (l: seq[Log]): Duration =
    var d = initDuration()
    for i, v in l:
        d = d + (v.endAt.get(now()) - v.startAt.get())
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
    if len(l) == 0:
        quit("Nothing to show", 0)
    var t = newTable(@["SL", "Event", "Start", "End", "Duration"])
    for i, v in l:
        var r = TableRow(
            column: @[
                $(i+1),
                v.title,
                v.startAt.get().toTime().format("hh:mm tt", zone = local()),
                if isNone(v.endAt): "" else: v.endAt.get().toTime().format("hh:mm tt", zone = local()),
                prettyDuration(v.endAt.get(now()) - v.startAt.get())
            ]
        )
        addToTable(t, r)
    t.show
    if len(l) > 1:
        echo "Total: ", prettyDuration(calcTimeSpent(l))

proc coreIn *(): void =
    let logLast = getLogLastOne()
    if isSome(logLast) and isNone(logLast.get().endAt):
        quit("You are already logged in", 2)
    if paramCount() < 2:
        help()
        quit(1)
    let title = paramStr(2)
    var l = Log(startAt: some(now()), title: title)
    insertLog(l)
    echo "You are now logged in"

proc coreOut *(): void =
    let logLast = getLogLastOne()
    if isNone(logLast):
        quit("You are not logged in")
    if isSome(logLast.get().endAt):
        quit("You are already logged out", 2)
    var l = logLast.get()
    l.endAt = some(now())
    updateLog(l)
    echo "You are now logged out of \"", l.title, "\""

proc logLast (): void =
    var n: int = 10
    try:
        n = parseInt(paramStr(2))
    except: discard
    let l = getLogLast(n)
    echoTable(l)

proc logLastHour (): void =
    var n = 60
    try:
        n = parseInt(paramStr(3))
    except: discard
    let l = getLogLastNMinute(n * 60)
    echoTable(l)

proc logLastDay (): void =
    var n = 1
    try:
        n = parseInt(paramStr(3))
    except: discard
    let l = getLogLastDay(1)
    echoTable(l)

proc logToday (): void =
    let date = now().format("yyyy-MM-dd")
    let l = getLogLastDay(date)
    echoTable(l)

proc logYesterday (): void =
    let date = (now() - initDuration(days = 1)).format("yyyy-MM-dd")
    let l = getLogLastDay(date)
    echoTable(l)

proc coreLog *(): void =
    var timespan: string
    if paramCount() < 2:
        timespan = "today"
    else:
        timespan = paramStr(2)
    case timespan
    of "hour":
        logLastHour()
    of "day":
        logLastDay()
    of "today":
        logToday()
    of "yesterday":
        logYesterday()
    else:
        logLast()
