require! <[fs path jsdom]>
block = require "@plotdb/block"

lib = path.dirname fs.realpathSync(__filename.replace(/\(.*/,''))

window = new jsdom.JSDOM("<!DOCTYPE html><html><body></body></html>", {url: 'http://localhost'}).window
block.env window
base = "http://localhost:3456"
mgr = new block.manager do
  registry: ({name,version,path,type}) ->
    if type != \block => return "#base/assets/lib/#name/#{version or 'main'}/#{path or 'index.min.js'}"
    ret = /^@plotdb\/konfig$/.exec(name)
    if !ret => return "#base/block/#name/#{version or 'main'}/#{path or 'index.html'}"
    return "#base/block/#{if /\//.exec(path) => '' else 'default/'}#{path or 'index.html'}"
set = <[default bootstrap]>
root = path.join(lib, "../web/static/block")
bs = set
  .map (s) ->
    r = path.join(root, s)
    fs.readdir-sync r .map -> name: "@plotdb/konfig", version: "main", path: "#s/#it"
  .reduce(((a,b) -> a ++ b),[])

mgr.bundle blocks: bs
  .then ->
    console.log it.code

