import std/[times, sha1, strformat, osproc]

proc genID(): string =
  getTime().format("yyyyMMddmm")


proc newNote*(args: seq[string], zkdir: string): (string, SecureHash) =
  let
    noteID = genID()
    noteTemplate = "Test note template"
    notePath = &"{zkdir}/{noteID}.tex"

  writeFile(notePath, noteTemplate)

  discard execCmd(fmt"nvim {notePath}")
  let noteHash = secureHashFile(notePath)

  return (noteID, noteHash)

