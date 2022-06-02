import
  std/[os, strutils, editdistance, sequtils, sugar, re, stats, strformat,
       algorithm],
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


func levenshteinRatio*(s1, s2: string): float =
  1 - editDistance(s1, s2) / max(s1.len, s2.len)


func fuzzyMatchWords*(words: seq[string], keyword: string): float =
  max(words.map(word => levenshteinRatio(word, keyword)))


func matchScore*(noteWords, keywords: seq[string]): float =
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


proc show*(results: SearchResults, numbered: bool = false) =
  for i, res in results.pairs:
    if numbered:
      stdout.write(&"{i}.\t")
    stdout.writeLine(&"{res.id} | {res.title}")
