import std/[strutils, sequtils, algorithm]

type TableRow * = ref object
    column*: seq[string]

type Table * = ref object
    column*: seq[int]
    titles*: seq[string]
    rows: seq[TableRow]

proc newTable *(titles: seq[string]): Table =
    var t = Table()
    t.titles = titles
    t.column = newSeqWith(len(titles), 0)
    for i, v in titles:
        t.column[i] = len(v)
    t

proc addToTable *(t: var Table, r: TableRow): void =
    if len(r.column) != len(t.titles):
        "invalid number of columns".quit(1)
    for i, v in r.column:
        if t.column[i] < len(v):
            t.column[i] = len(v)
    insert(t.rows, r)

proc width (t: Table): int =
    foldl(t.column, a + b) + (3 * len(t.titles)) + 1

proc show *(t: var Table): void =
    echo "-".repeat(t.width)
    stdout.write "| "
    for i, title in t.titles:
        stdout.write(alignLeft(title, t.column[i]), " | ")
    stdout.write "\n"
    echo "-".repeat(t.width)
    for r in t.rows.reversed:
        stdout.write "| "
        for i, c in r.column:
            stdout.write(alignLeft(c, t.column[i]), " | ")
        stdout.write "\n"
    echo "-".repeat(t.width)
