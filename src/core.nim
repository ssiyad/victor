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
    let logLast = getLogLastOne().get(Log())
    if isNone(logLast.endAt):
        quit("You are already logged in", 2)
    if paramCount() < 2:
        help()
        quit(1)
    let title = paramStr(2)
    var l = Log(startAt: some(now()), title: title)
    insertLog(l)
    echo "You are now logged in"

proc coreOut *(): void =
    var l = getLogLastOne().get(Log())
    if not isNone(l.endAt):
        quit("You are already logged out", 2)
    l.endAt = some(now())
    updateLog(l)
    echo "You are now logged out of \"", l.title, "\""

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
