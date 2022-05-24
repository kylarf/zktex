import std/[os, parsecfg, tables]

let
  zkdir = getHomeDir() / "zktex"
  defaults = {
    "editor": "nvim",
    "viewer": "zathura",
    "texcmd": "latexmk",
    "zkdir": zkdir,
    "texcls": zkdir / "jyzk.cls",
    "template": zkdir / "template.tex"
  }.toOrderedTable()


type
  ZkConfig* = ref object
    user*: Config
    default*: OrderedTable[string, string]


proc getConfig*(): ZkConfig =
  let configDir = getConfigDir() / "zktex"
  discard existsOrCreateDir(configDir)
  let configFile = configDir / "zktex.cfg"

  if not fileExists(configFile):
    writeFile(configFile, "")

  return ZkConfig(user: loadConfig(configFile), default: defaults)


proc `[]`*(settings: ZkConfig, key: string): string =
  return settings.user.getSectionValue("", key, settings.default[key])

