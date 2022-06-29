import
  std/[os, strutils, editdistance, sequtils, sugar, re, stats, strformat,
       algorithm, parseutils]

const
  NonAlphaNum = AllChars - Digits - Letters
  noteFilePattern = "[0-9]*.tex"

let noteTitlePattern = re"(?<=\\notetitle\{)(.*)(?=\})"


type
  SearchResult* = object
    id*: string
    title*: string
    score*: float

  SearchResults* = seq[SearchResult]


func splitKeywords(text: string): seq[string] =
  text.split(NonAlphaNum).filter(x => x != "")


proc getTitle(noteText: string): string =
  let (initial, final) = noteText.findBounds(noteTitlePattern)
  if initial == -1: ""
  else: noteText[initial .. final]


func levRatio(s1, s2: string): float =
  1 - editDistance(s1, s2) / max(s1.len, s2.len)


func fuzzyMatchWords(words: seq[string], keyword: string): float =
  max(words.map(word => levRatio(word, keyword)))


func matchScore(noteWords, keywords: seq[string]): float =
  mean(keywords.map(kw => noteWords.fuzzyMatchWords(kw)))


proc findKeywords*(keywords: seq[string], path: string): SearchResults =
  setCurrentDir(path)
  collect:
    for note in walkFiles(noteFilePattern):
      let
        noteText = readFile(note)
        noteWords = noteText.splitKeywords()
        score = noteWords.matchScore(keywords)
      if score >= 0.8:
        let
          noteID = splitFile(note).name
          title = noteText.getTitle()
        SearchResult(id: noteID, title: title, score: score)


proc sortResults*(results: var SearchResults) =
  results.sort do (a, b: SearchResult) -> int:
    cmp(a.score, b.score)


proc listResults*(results: SearchResults, numbered: bool = false) =
  if results.len == 0:
    stdout.writeLine("No results found.")
  else:
    for i, res in results.pairs:
      if numbered:
        stdout.write(&"{i+1}.\t")
      stdout.writeLine(&"{res.id}\t{res.title}")


func isIntStr(s: string): bool =
  var n: int
  s.parseInt(n) == s.len


func inBounds(selection: seq[string], resultsLen: int): bool =
  let idxs = selection.map(parseInt)
  all(idxs, x => x in 1..resultsLen)


proc select*(results: SearchResults): seq[string] =
  case results.len:
    of 0:
      @[]
    of 1:
      @[results[0].id]
    else:
      stdout.write("Enter space-delimited indices of desired notes: ")
      var selection = stdin.readLine().splitWhitespace()
      while not (all(selection, isIntStr) and inBounds(selection, results.len)):
        stdout.writeLine("Numeric, space-delimited values within range of displayed results only.")
        stdout.write("Enter space-delimited indices of desired notes: ")
        selection = stdin.readLine().splitWhitespace()
      collect:
        for idx in selection.map(parseInt):
          results[idx-1].id
