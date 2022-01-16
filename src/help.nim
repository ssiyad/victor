let helpString: string = """
Usage:
    victor command
Commands
    in [note]
        To log as in
    out [note]
        To log as out
    log hour/day
        To get the log of last day/hour"""

proc help *(): void =
    echo helpString
