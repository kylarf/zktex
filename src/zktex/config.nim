import std/[os, parsecfg, strformat, tables]

const defaults = {
  "editor": "nvim",
  "texCommand": "latexmk",
  "viewer": "zathura",
  "zkdir": &"{getHomeDir()}/zktex"
}.toOrderedTable()


type
  ZkConfig* = ref object
    user*: Config
    default*: OrderedTable[string, string]


proc getConfig*(): ZkConfig =
  let configDir = &"{getConfigDir()}/zktex"
  discard existsOrCreateDir(configDir)
  let configFile = &"{configDir}/zktex.cfg"

  if not fileExists(configFile):
    writeFile(configFile, "")

  return ZkConfig(user: loadConfig(configFile), default: defaults)


proc `[]`*(settings: ZkConfig, key: string): string =
  return settings.user.getSectionValue("", key, settings.default[key])

