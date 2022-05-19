import std/[os, json, strformat, sha1]
import zktex/new

let
  zkdir = expandTilde("~/.zktex")
  hashedNotesPath = fmt"{zkdir}/hashes.json"


proc usage() =
  echo "TODO: Print usage to console."


proc loadHashes(): JsonNode =
  try:
    return parseJson(readFile(hashedNotesPath))
  except IOError:
    echo "Creating JSON hash file"
    writeFile(hashedNotesPath, "{}")
    return parseJson(readFile(hashedNotesPath))


proc saveHashes(noteHashes: JsonNode) =
  writeFile(hashedNotesPath, pretty(noteHashes))


proc main() =
  let noteHashes = loadHashes()

  if paramCount() < 1:
    usage()
  else:
    discard existsOrCreateDir(zkdir)
    let args = commandLineParams()[1..^1]

    case paramStr(1):
      of "new":
        let (noteID, noteHash) = newNote(args)
        noteHashes[noteID] = % $noteHash
      else:
        usage()

    saveHashes(noteHashes)


when isMainModule:
  main()
