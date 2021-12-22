<- (->it.apply {}) _

@manager = new block.manager do
  registry: ({name,version,path,type}) ->
    if type == \block => "/block/#name/#version/#{path or 'index.html'}"
    else "/assets/lib/#name/#version/#{path or ''}"

@manager.debundle url: "/assets/bundle/index.html"
  .then ~>
    @meta =
      number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1, default: 24
      font: name: \font, type: \font
    kfg-cfg =
      root: document.querySelector('[ld=kfg]')
      debounce: false
      meta: @meta
      view: \default
      manager: @manager
      typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}
    kfg-cfg <<<
      use-bundle: false
      manager: new block.manager registry: ({name, version, path, type}) ->
        if type == \block =>
          ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
          return if !ret => "/block/#name/#version/index.html"
          else "/block/#{ret.1}/#path/index.html"
        else return "/assets/lib/#name/#version/#{path or 'index.min.js'}"
    cfg = new konfig kfg-cfg
    cfg.init!
  .then ->
    console.log '@plotdb/konfig cfg inited with init config:', it
