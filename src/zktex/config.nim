import std/[os, parsecfg, strformat]

proc getConfig*(): Config =
  let configDir = &"{getConfigDir()}/zktex"
  discard existsOrCreateDir(configDir)
  let configFile = &"{configDir}/zktex.cfg"

  if not fileExists(configFile):
    writeFile(configFile, "")

  return loadConfig(configFile)

