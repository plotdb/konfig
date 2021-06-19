require! <[fs]>
files = fs.readdir-sync "web/static/block" .map -> [it, "web/static/block/#it/0.0.1/index.html"]
ret = files.map (file) -> {name: file.0, version: "0.0.1", code:  (fs.read-file-sync file.1 .toString!)}
console.log """
config.pack = #{JSON.stringify(ret)};
"""

