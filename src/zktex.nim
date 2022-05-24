import
  std/[os, json, sha1],
  zktex/[new, config]

const
  zkTemplate = staticRead("../TeX/template.tex")
  zkClass = staticRead("../TeX/jyzk.cls")

let
  settings = getConfig()
  zkdir = settings["zkdir"].expandTilde()
  hashedNotesPath = zkdir / "hashes.json"


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


proc initDir() =
  discard existsOrCreateDir(zkdir)

  if not fileExists(settings["template"]):
    writeFile(settings["template"], zkTemplate)

  if not fileExists(settings["texcls"]):
    writeFile(settings["texcls"], zkClass)


proc main() =
  if paramCount() < 1:
    usage()
  else:
    initDir()
    let noteHashes = loadHashes()
    let args = commandLineParams()[1..^1]

    case paramStr(1):
      of "new":
        let (noteID, noteHash) = newNote(args, settings)
        noteHashes[noteID] = % $noteHash
      else:
        usage()

    saveHashes(noteHashes)


when isMainModule:
  main()

