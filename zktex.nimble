# Package

version       = "0.1.0"
author        = "kylarf"
description   = "A CLI note-taking utility based on the Zettelkasten method and LaTeX"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
namedBin      = {"zktex": "zk"}.toTable()

# Dependencies

requires "nim >= 1.6.4"
