view = new ldview do
  root: document.body
  init:
    kfg: ({node}) ->
      console.log \here
      kfg = new konfig do
        root: node
        view: \default
        manager: new block.manager do
          registry:
            block: ({name,version,path}) -> "/assets/block/#name/#version/#{path or 'index.html'}"
            lib: ({name,version,path}) -> "/assets/lib/#name/#version/#path"
        typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}
        meta:
          number: type: \number
      kfg.init!
        .then ->
view.render!
