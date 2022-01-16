import std/os

import src/core
import src/help

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
else:
    help()
