require! <[fs path @plotdb/block jsdom]>

window = new jsdom.JSDOM("<!DOCTYPE html><html><body></body></html>", {url: 'http://localhost'}).window
block.env window
base = "http://localhost:63860"
mgr = new block.manager do
  registry: ({name,version,path,type}) ->
    if type != \block => return "#base/assets/lib/#name/#{version or 'main'}/#{path or 'index.min.js'}"
    ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
    if !ret => return "#base/block/#name/#{version or 'main'}/#{path or 'index.html'}"
    return "#base/block/#{ret.1}/#{path or 'index.html'}"
set = <[default bootstrap]>
root = "../web/static/block"
bs = set
  .map (s) ->
    r = path.join(root, s)
    fs.readdir-sync r .map -> name: "@plotdb/konfig.widget.#s", version: "master", path: "#it"
  .reduce(((a,b) -> a ++ b),[])

/*
bs = [ <[default base]> <[default number]> <[bootstrap base]> <[bootstrap number]> ]
bs = bs.map ([s,it]) ->
  console.log s, it
  name: "@plotdb/konfig.widget.#s", version: "main", path: "#it/index.html"
*/

mgr.bundle blocks: bs
  .then -> fs.write-file-sync "../web/static/assets/bundle/index.html", it

