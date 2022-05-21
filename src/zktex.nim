import
  std/[os, json, parsecfg, strformat, sha1],
  zktex/[new, config]

let
  settings = getConfig()
  zkdir = settings.getSectionValue("", "zkdir", &"{getHomeDir()}/zktex")
  hashedNotesPath = &"{zkdir}/hashes.json"


proc usage() =
  echo "TODO: Print usage to console."


proc loadHashes(): JsonNode =
  try:
    return parseJson(readFile(hashedNotesPath))
  except IOError:
    writeFile(hashedNotesPath, "{}")
    return parseJson(readFile(hashedNotesPath))


proc saveHashes(noteHashes: JsonNode) =
  writeFile(hashedNotesPath, pretty(noteHashes))


proc main() =
  if paramCount() < 1:
    usage()
  else:
    discard existsOrCreateDir(zkdir)
    let noteHashes = loadHashes()
    let args = commandLineParams()[1..^1]

    case paramStr(1):
      of "new":
        let (noteID, noteHash) = newNote(args, zkdir)
        noteHashes[noteID] = % $noteHash
      else:
        usage()

    saveHashes(noteHashes)


when isMainModule:
  main()

