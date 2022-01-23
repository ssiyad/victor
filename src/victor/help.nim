import system

let helpString: string = """
Usage:
    victor command
Commands
    in <note>
        To log as in
    out
        To log as out
    log hour/day
        To get the log of last day/hour
    version
        To get version information"""

proc help *(): void =
    echo helpString

proc version *(): void =
    const NimblePkgVersion {.strdefine.} = "Unknown"
    echo "Version ", NimblePkgVersion
    echo "Compiled: ", CompileDate, " ", CompileTime, " UTC"
    echo "https://github.com/ssiyad/victor"
