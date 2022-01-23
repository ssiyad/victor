import system

let helpString: string = """
Usage:
    victor command
Commands
    in <title>
        To log as in, `title` is necessary
    out
        To log as out
    log
        - hour <n>
            To get the log of `n` hours, default to 1
        - day <n>
            To get the log of `n` days, default to 1
        - today
            To get today's log
        - yesterday
            To get yesterday's log
    version
        To get version information"""

proc help *(): void =
    echo helpString

proc version *(): void =
    const NimblePkgVersion {.strdefine.} = "Unknown"
    echo "Version ", NimblePkgVersion
    echo "Compiled: ", CompileDate, " ", CompileTime, " UTC"
    echo "https://github.com/ssiyad/victor"
