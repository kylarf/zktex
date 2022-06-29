import
  std/[os, times, sha1, strformat, osproc],
  common/config

proc genID(): string =
  getTime().format("yyyyMMddHHmm")


proc newNote*(args: seq[string], settings: ZkConfig): (string, SecureHash) =
  let
    noteID = genID()
    zkdir = settings["zkdir"].expandTilde()
    noteTemplate = readFile(settings["template"].expandTilde())
    notePath = zkdir / &"{noteID}.tex"
  writeFile(notePath, noteTemplate)
  discard execCmd(&"""{settings["editor"]} {notePath}""")
  (noteID, secureHashFile(notePath))
