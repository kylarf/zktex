import
  std/[os, strutils, editdistance, sequtils, sugar, re, tables, stats],
  ./config

const NonAlphaNum* = AllChars - Digits - Letters


type
  SearchResult* = object
    title*: string
    score*: float


func levenshteinRatio*(s1, s2: string): float =
  1 - editDistance(s1, s2) / max(s1.len, s2.len)


func splitKeywords*(text: string): seq[string] =
  text.split(NonAlphaNum).filter(x => x != "")


func getTitle*(noteText: string): string =
  let
    pattern = re"(?<=\\notetitle\{)(.*)(?=\})"
    (initial, final) = noteText.findBounds(pattern)
  
  if initial == -1:
    return ""
  else:
    return noteText[initial .. final]


func fuzzyMatchWords*(words: seq[string], keyword: string): float =
  max(words.map(word => levenshteinRatio(word, keyword)))


proc findKeywords*(keywords, args: seq[string], settings: ZkConfig):
                   TableRef[string, SearchResult] =
  setCurrentDir(settings["zkdir"].expandTilde)

  let
    noteFilePattern = "[0-9]*.tex"
  var
    noteText, noteID, title: string
    noteWords: seq[string]
    score: float
  result = newTable[string, SearchResult]()

  for note in walkFiles(noteFilePattern):
    noteText = readFile(note)
    noteWords = noteText.splitKeywords()
    score = mean(keywords.map(kw => noteWords.fuzzyMatchWords(kw)))
    if score >= 0.8:
      noteID = splitFile(note).name
      title = noteText.getTitle()
      result[noteID] = SearchResult(title: title, score: score)
