import std/os

import victor/core
import victor/help

if paramCount() == 0:
    help()
    quit(0)

case paramStr(1)
of "in":
    core.coreIn()
of "out":
    core.coreOut()
of "log":
    core.coreLog()
of "version":
    version()
else:
    help()
