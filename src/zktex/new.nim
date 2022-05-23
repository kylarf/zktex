import
  std/[os, times, sha1, strformat, osproc],
  ./config

proc genID(): string =
  getTime().format("yyyyMMddmm")


proc newNote*(args: seq[string], settings: ZkConfig): (string, SecureHash) =
  let
    noteID = genID()
    noteTemplate = "Test note template"
    zkdir = settings["zkdir"].expandTilde()
    notePath = zkdir / &"{noteID}.tex"

  writeFile(notePath, noteTemplate)

  discard execCmd(&"""{settings["editor"]} {notePath}""")
  let noteHash = secureHashFile(notePath)

  return (noteID, noteHash)

