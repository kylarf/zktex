import
  std/[os, json, sha1],
  zktex/[new, common/config],
  fusion/matching

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
  parseJson(readFile(hashedNotesPath))


proc saveHashes(noteHashes: JsonNode) =
  writeFile(hashedNotesPath, pretty(noteHashes))


proc initDir() =
  let
    templatePath = settings["template"].expandTilde()
    texClassPath = settings["texcls"].expandTilde()

  discard existsOrCreateDir(zkdir)

  if not fileExists(templatePath):
    writeFile(templatePath, zkTemplate)

  if not fileExists(texClassPath):
    writeFile(texClassPath, zkClass)

  if not fileExists(hashedNotesPath):
    writeFile(hashedNotesPath, "{}")


proc main() =
  if paramCount() < 1:
    usage()

  else:
    initDir()

    let noteHashes = loadHashes()
    [@subCmd, all @args] := commandLineParams()

    case subCmd:
      of "new":
        let (noteID, noteHash) = newNote(args, settings)
        noteHashes[noteID] = % $noteHash
      else:
        usage()

    saveHashes(noteHashes)


when isMainModule:
  main()

