import
  std/[os, strutils, editdistance, sequtils, sugar, re, stats, strformat,
       algorithm, parseutils],
  ./config

const
  NonAlphaNum* = AllChars - Digits - Letters
  noteFilePattern = "[0-9]*.tex"


type
  SearchResult* = object
    id*: string
    title*: string
    score*: float

  SearchResults* = seq[SearchResult]


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


func levRatio(s1, s2: string): float =
  1 - editDistance(s1, s2) / max(s1.len, s2.len)


func fuzzyMatchWords(words: seq[string], keyword: string): float =
  max(words.map(word => levRatio(word, keyword)))


func matchScore(noteWords, keywords: seq[string]): float =
  mean(keywords.map(kw => noteWords.fuzzyMatchWords(kw)))


proc findKeywords*(keywords: seq[string], path: string): SearchResults =
  setCurrentDir(path)
  result = collect:
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
  for i, res in results.pairs:
    if numbered:
      stdout.write(&"{i}.\t")
    stdout.writeLine(&"{res.id} | {res.title}")


func isInt(s: string): bool =
  var n: int
  s.parseInt(n) == s.len


func allInBounds(selection: seq[string], resultsLen: int): bool =
  let idxs = selection.map(parseInt)
  all(idxs, x => x >= 0 and x < resultsLen)


proc select*(results: SearchResults): seq[string] =
  stdin.write("Enter space-delimited indices of desired notes: ")
  var selection: seq[string] = stdin.readLine().splitWhitespace()
  while not all(selection, isInt) or not allInBounds(selection, results.len):
    stdin.writeLine("""Numeric, space-delimited values within range of
                    displayed results only.""")
    selection = stdin.readLine().splitWhitespace()

  result = collect:
    for idx in selection.map(parseInt):
      results[idx].id
