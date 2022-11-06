require! <[fs yargs]>
argv = yargs
  .option \set, do
    alias: \s
    description: "set name. default `default`."
    type: \string
  .help \help
  .alias \help, \h
  .check (argv, options) -> return true
  .argv

set = argv.s or 'default'

root = "web/static/block/#set"
files = fs.readdir-sync root
  .map -> [it, "#root/#it/index.html"]
  .filter -> fs.exists-sync(it.1)
ret = files.map (file) ->
  dir = if set != \default => "#set/" else ''
  {
    name: "@plotdb/konfig"
    version: "main"
    path: "#dir#{file.0}"
    code: (fs.read-file-sync file.1 .toString!)
  }
console.log """
konfig.bundle = (konfig.bundle || []).concat(#{JSON.stringify(ret)});
"""

